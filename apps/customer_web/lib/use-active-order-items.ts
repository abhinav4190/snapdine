import { collection, onSnapshot, query, where } from "firebase/firestore";
import { useEffect, useState } from "react";
import { db } from "./firebase";

export interface TrackedItem {
  id: string;
  orderId: string;
  name: string;
  qty: number;
  price: number;
  status: "pending" | "preparing" | "done";
}

export function useActiveOrderItems(cafeId: string, tableId: string) {
  const [items, setItems] = useState<TrackedItem[]>([]);

  useEffect(() => {
    if (!cafeId || !tableId) return;

    const ordersQuery = query(
      collection(db, "cafes", cafeId, "orders"),
      where("tableId", "==", tableId),
      where("isPaid", "==", false)
    );

    const itemUnsubs = new Map<string, () => void>();
    const itemsByOrder = new Map<string, TrackedItem[]>();

    const flatten = () => {
      const all: TrackedItem[] = [];
      itemsByOrder.forEach((list) => all.push(...list));
      setItems(all);
    };

    const unsubOrders = onSnapshot(ordersQuery, (snap) => {
      const currentIds = new Set(snap.docs.map((d) => d.id));

      itemUnsubs.forEach((unsub, orderId) => {
        if (!currentIds.has(orderId)) {
          unsub();
          itemUnsubs.delete(orderId);
          itemsByOrder.delete(orderId);
        }
      });

      snap.docs.forEach((orderDoc) => {
        if (itemUnsubs.has(orderDoc.id)) return;
        const unsub = onSnapshot(
          collection(db, "cafes", cafeId, "orders", orderDoc.id, "items"),
          (itemsSnap) => {
            itemsByOrder.set(
              orderDoc.id,
              itemsSnap.docs.map((d) => ({
                id: d.id,
                orderId: orderDoc.id,
                name: d.data().name,
                qty: d.data().qty,
                price: d.data().price,
                status: d.data().status,
              }))
            );
            flatten();
          }
        );
        itemUnsubs.set(orderDoc.id, unsub);
      });

      flatten();
    });

    return () => {
      unsubOrders();
      itemUnsubs.forEach((unsub) => unsub());
    };
  }, [cafeId, tableId]);

  return items;
}