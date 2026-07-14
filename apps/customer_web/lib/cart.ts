import { doc, getDoc, onSnapshot, setDoc } from "firebase/firestore";
import { db } from "./firebase";

export interface CartItem {
  menuItemId: string;
  name: string;
  price: number;
  qty: number;
}

function cartRef(cafeId: string, tableId: string) {
  return doc(db, "cafes", cafeId, "tables", tableId, "cart", "current");
}

export function streamCart(
  cafeId: string,
  tableId: string,
  callback: (items: CartItem[]) => void,
) {
  return onSnapshot(cartRef(cafeId, tableId), (snap) => {
    callback(snap.exists() ? ((snap.data().items as CartItem[]) ?? []) : []);
  });
}

async function writeCart(
  cafeId: string,
  tableId: string,
  token: string,
  items: CartItem[],
) {
  await setDoc(cartRef(cafeId, tableId), {
    items,
    secretTokenCheck: token,
    updatedAt: Date.now(),
  });
}

export async function addToCart(
  cafeId: string,
  tableId: string,
  token: string,
  item: CartItem,
) {
  const snap = await getDoc(cartRef(cafeId, tableId));
  const current: CartItem[] = snap.exists() ? (snap.data().items ?? []) : [];

  const existingIndex = current.findIndex(
    (i) => i.menuItemId === item.menuItemId,
  );

  const updated =
    existingIndex >= 0
      ? current.map((i, idx) =>
          idx === existingIndex ? { ...i, qty: i.qty + item.qty } : i,
        )
      : [...current, item];

  await writeCart(cafeId, tableId, token, updated);
}

export async function updateQty(
  cafeId: string,
  tableId: string,
  token: string,
  menuItemId: string,
  qty: number,
) {
  const snap = await getDoc(cartRef(cafeId, tableId));
  if (!snap.exists()) return;
  const current: CartItem[] = snap.data().items ?? [];

  const updated =
    qty <= 0
      ? current.filter((i) => i.menuItemId !== menuItemId)
      : current.map((i) => (i.menuItemId === menuItemId ? { ...i, qty } : i));

   await writeCart(cafeId, tableId, token, updated);
}
