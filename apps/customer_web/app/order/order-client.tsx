"use client";

import { useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import { collection, onSnapshot } from "firebase/firestore";
import { Plus, Minus, ShoppingBagOpen, WarningCircle } from "@phosphor-icons/react";
import { db } from "@/lib/firebase";
import { verifyTable, CafeConfig } from "@/lib/verify-table";
import { streamCart, addToCart, updateQty, CartItem } from "@/lib/cart";

interface MenuItem {
  id: string;
  name: string;
  proce: number;
  category: string;
  description: string;
  isAvailable: boolean;
}

export default function OrderClient() {
  const params = useSearchParams();
  const cafeId = params.get("cafeId") ?? "";
  const tableId = params.get("tableId") ?? "";
  const token = params.get("token") ?? "";

  const [status, setStatus] = useState<"loading" | "invalid" | "ready">("loading");
  const [cafeName, setCafeName] = useState("");
  const [config, setConfig] = useState<CafeConfig | null>(null);
  const [menu, setMenu] = useState<MenuItem[]>([]);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [cartOpen, setCartOpen] = useState(false);

  useEffect(() => {
    if (!cafeId || !tableId || !token) {
      setStatus("invalid");
      return;
    }
    verifyTable(cafeId, tableId, token).then((result) => {
      if (!result.valid) {
        setStatus("invalid");
        return;
      }
      setCafeName(result.cafeName);
      setConfig(result.config);
      setStatus("ready");
    });
  }, [cafeId, tableId, token]);

  useEffect(() => {
    if (status !== "ready") return;
    const unsub = onSnapshot(collection(db, "cafes", cafeId, "menu"), (snap) => {
      setMenu(snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<MenuItem, "id">) })));
    });
    return unsub;
  }, [status, cafeId]);

  useEffect(() => {
    if (status !== "ready") return;
    const unsub = streamCart(cafeId, tableId, setCart);
    return unsub;
  }, [status, cafeId, tableId]);

  if (status === "loading") {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <p className="text-sm text-inkFaint">Loading menu…</p>
      </div>
    );
  }

  if (status === "invalid") {
    return (
      <div className="flex min-h-screen items-center justify-center px-8 text-center">
        <div>
          <WarningCircle size={32} weight="thin" className="mx-auto mb-3 text-rosewood" />
          <p className="text-base font-semibold">This QR code isn&apos;t valid</p>
          <p className="mt-1.5 text-sm text-inkFaint">
            Ask a staff member to scan a fresh code for your table.
          </p>
        </div>
      </div>
    );
  }

  const categories = Array.from(new Set(menu.map((m) => m.category)));
  const cartTotal = cart.reduce((sum, i) => sum + i.price * i.qty, 0);
  const cartCount = cart.reduce((sum, i) => sum + i.qty, 0);

  const handleAdd = (item: MenuItem) => {
    addToCart(cafeId, tableId, token, {
      menuItemId: item.id,
      name: item.name,
      price: item.proce,
      qty: 1,
    });
  };

  return (
    <div className="mx-auto max-w-md pb-28">
      <header className="px-6 pb-5 pt-10">
        <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-inkFaint">
          Table {tableId.replace("table-", "")}
        </p>
        <h1 className="mt-1 text-[26px] font-bold leading-tight">{cafeName}</h1>
      </header>

      {categories.map((category) => (
        <section key={category} className="px-6 py-5">
          <div className="perforation mb-3 flex items-center pb-2">
            <h2 className="text-[13px] font-semibold uppercase tracking-[0.1em] text-inkFaint">
              {category}
            </h2>
          </div>
          <div>
            {menu
              .filter((m) => m.category === category)
              .map((item) => (
                <div key={item.id} className="perforation flex items-baseline gap-2 py-4">
                  <div className="min-w-0">
                    <p className="font-medium">{item.name}</p>
                    {item.description && (
                      <p className="mt-0.5 text-[13px] text-inkFaint">{item.description}</p>
                    )}
                  </div>
                  <span className="leader" />
                  <span className="tabular shrink-0 font-semibold">₹{item.proce}</span>
                  <button
                    disabled={!item.isAvailable}
                    onClick={() => handleAdd(item)}
                    className={`ml-2 flex h-8 w-8 shrink-0 items-center justify-center rounded-full ${
                      item.isAvailable
                        ? "bg-moss text-paper"
                        : "bg-rule text-inkFaint"
                    } disabled:cursor-not-allowed`}
                    aria-label={item.isAvailable ? `Add ${item.name}` : `${item.name} sold out`}
                  >
                    <Plus size={16} weight="bold" />
                  </button>
                </div>
              ))}
          </div>
        </section>
      ))}

      {cartCount > 0 && (
        <button
          onClick={() => setCartOpen(true)}
          className="fixed bottom-5 left-1/2 flex w-[calc(100%-2.5rem)] max-w-md -translate-x-1/2 items-center justify-between rounded-full bg-ink px-6 py-4 text-paper"
        >
          <span className="flex items-center gap-2 text-sm font-medium">
            <ShoppingBagOpen size={18} weight="thin" />
            {cartCount} item{cartCount > 1 ? "s" : ""}
          </span>
          <span className="tabular font-semibold">₹{cartTotal}</span>
        </button>
      )}

      {cartOpen && (
        <div
          className="fixed inset-0 z-10 flex items-end bg-ink/50"
          onClick={() => setCartOpen(false)}
        >
          <div
            className="w-full max-w-md mx-auto max-h-[75vh] overflow-y-auto rounded-t-[28px] bg-paper px-6 pb-8 pt-6"
            style={{
              maskImage:
                "linear-gradient(to bottom, transparent 0, black 12px)",
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="mx-auto mb-5 h-1 w-10 rounded-full bg-rule" />
            <p className="mb-4 text-[15px] font-semibold uppercase tracking-[0.08em] text-inkFaint">
              Your order
            </p>
            {cart.map((item) => (
              <div key={item.menuItemId} className="perforation flex items-center justify-between py-3">
                <div>
                  <p className="font-medium">{item.name}</p>
                  <p className="tabular text-[13px] text-inkFaint">
                    ₹{item.price} × {item.qty}
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <button
                    onClick={() => updateQty(cafeId, tableId, token, item.menuItemId, item.qty - 1)}
                    className="flex h-7 w-7 items-center justify-center rounded-full bg-rule/60"
                  >
                    <Minus size={13} weight="bold" />
                  </button>
                  <span className="tabular w-4 text-center text-sm">{item.qty}</span>
                  <button
                    onClick={() => updateQty(cafeId, tableId, token, item.menuItemId, item.qty + 1)}
                    className="flex h-7 w-7 items-center justify-center rounded-full bg-rule/60"
                  >
                    <Plus size={13} weight="bold" />
                  </button>
                </div>
              </div>
            ))}
            <div className="mt-4 flex justify-between border-t border-dashed border-rule pt-4">
              <span className="font-semibold">Total</span>
              <span className="tabular font-semibold">₹{cartTotal}</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}