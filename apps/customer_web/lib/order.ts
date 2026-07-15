import {
  addDoc,
  collection,
  doc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import { CartItem } from "./cart";
import { db } from "./firebase";

export async function placeOrder(
  cafeId: string,
  tableId: string,
  token: string,
  items: CartItem[],
) {
  const orderRef = await addDoc(collection(db, "cafes", cafeId, "orders"), {
    tableId,
    secretTokenCheck: token,
    createdBy: "customer",
    isPaid: false,
    createdAt: serverTimestamp(),
  });

  await Promise.all(
    items.map((item) =>
      addDoc(collection(db, "cafes", cafeId, "orders", orderRef.id, "items"), {
        cafeId,
        tableId,
        menuItemId: item.menuItemId,
        name: item.name,
        price: item.price,
        qty: item.qty,
        status: "pending",
        addedAt: serverTimestamp(),
      }),
    ),
  );

  await setDoc(doc(db, "cafes", cafeId, "tables", tableId, "cart", "current"), {
    items: [],
    secretTokenCheck: token,
    updatedAt: Date.now(),
  });

  await updateDoc(doc(db, "cafes", cafeId, "tables", tableId), {
    status: "occupied",
    sessionStartedAt: serverTimestamp(),
    secretTokenCheck: token,
  });
}
