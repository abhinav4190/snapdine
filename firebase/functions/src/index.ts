import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";

initializeApp();
const auth = getAuth();
const db = getFirestore();

async function assertOwner(uid: string, cafeId: string) {
  const indexDoc = await db.doc(`staffIndex/${uid}`).get();
  if (!indexDoc.exists || indexDoc.data()?.cafeId !== cafeId) {
    throw new HttpsError("permission-denied", "Not staff of this cafe.");
  }
  const staffDoc = await db.doc(`cafes/${cafeId}/staff/${uid}`).get();
  if (!staffDoc.exists || staffDoc.data()?.role !== "owner") {
    throw new HttpsError("permission-denied", "owner access required.");
  }
}

export const createStaffAccount = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "must be signed in");
  }
  const { cafeId, email, password, name, phone, role } = request.data as {
    cafeId: string;
    email: string;
    password: string;
    name: string;
    phone: string;
    role: string;
  };

  if (!cafeId || !email || !password || !name || !role) {
    throw new HttpsError("invalid-argument", "Missing required fields.");
  }
  if (!["waiter", "chef"].includes(role)) {
    throw new HttpsError("invalid-argument", "Role must be waiter or chef.");
  }

  await assertOwner(request.auth.uid, cafeId);

  const userRecord = await auth.createUser({
    email,
    password,
    displayName: name,
  });

  await db.doc(`cafes/${cafeId}/staff/${userRecord.uid}`).set({
    role,
    name,
    phone: phone ?? "",
  });
  await db.doc(`staffIndex/${userRecord.uid}`).set({ cafeId, role });

  return { uid: userRecord.uid };
});

export const deleteStaffAccount = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }

  const { cafeId, staffUid } = request.data as {
    cafeId: string;
    staffUid: string;
  };
  if (!cafeId || !staffUid) {
    throw new HttpsError("invalid-argument", "Missing fields.");
  }

  await assertOwner(request.auth.uid, cafeId);

  if (staffUid === request.auth.uid) {
    throw new HttpsError(
      "failed-precondition",
      "Cannot delete your own account.",
    );
  }

  await auth.deleteUser(staffUid);
  await db.doc(`cafes/${cafeId}/staff/${staffUid}`).delete();
  await db.doc(`staffIndex/${staffUid}`).delete();

  return { success: true };
});
