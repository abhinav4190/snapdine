"use client";

import { useEffect, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { collection, onSnapshot } from "firebase/firestore";
import {
  Plus,
  Minus,
  ShoppingBagOpen,
  WarningCircle,
  Clock,
  CheckCircle,
  CookingPot,
  MagnifyingGlass,
  X,
  ForkKnife,
} from "@phosphor-icons/react";
import { db } from "@/lib/firebase";
import { verifyTable, CafeConfig } from "@/lib/verify-table";
import { streamCart, addToCart, updateQty, CartItem } from "@/lib/cart";
import { useActiveOrderItems } from "@/lib/use-active-order-items";
import { placeOrder } from "@/lib/order";
import { DotLottieReact } from "@lottiefiles/dotlottie-react";

interface MenuItem {
  id: string;
  name: string;
  price: number;
  category: string;
  description: string;
  isAvailable: boolean;
  imageUrl?: string;
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
  const [searchQuery, setSearchQuery] = useState("");
  const [activeCategory, setActiveCategory] = useState("All");
  const trackedItems = useActiveOrderItems(cafeId, tableId);
  const [placing, setPlacing] = useState(false);

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

  const categories = useMemo(
    () => ["All", ...Array.from(new Set(menu.map((m) => m.category)))],
    [menu]
  );

  const searching = searchQuery.trim().length > 0;

  const displayItems = useMemo(() => {
    const q = searchQuery.trim().toLowerCase();
    return menu.filter(
      (m) =>
        (activeCategory === "All" || m.category === activeCategory) &&
        (q === "" || m.name.toLowerCase().includes(q))
    );
  }, [menu, activeCategory, searchQuery]);

 if (status === "loading") {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center">
      <div className="h-60 w-60">
        <DotLottieReact
          src="https://lottie.host/4be06c91-b247-4800-b9d9-b5da1fe54255/kiHIhPKHPn.lottie"
          loop
          autoplay
        />
      </div>

      {/* <p className="mt-4 text-sm text-inkFaint">
        Loading menu
      </p> */}
    </div>
  );
}

  if (status === "invalid") {
    return (
      <div className="flex min-h-screen items-center justify-center px-8 text-center">
        <div>
          <WarningCircle size={32} weight="thin" className="mx-auto mb-3 text-rosewood" />
          <p className="text-base font-semibold">This QR code is not valid</p>
          <p className="mt-1.5 text-sm text-inkFaint">
            Ask staff member to scan a fresh code for your table.
          </p>
        </div>
      </div>
    );
  }

  const cartTotal = cart.reduce((sum, i) => sum + i.price * i.qty, 0);
  const cartCount = cart.reduce((sum, i) => sum + i.qty, 0);

  const trackedTotal = trackedItems.reduce((sum, i) => sum + i.price * i.qty, 0);

  const handleAdd = (item: MenuItem) => {
    addToCart(cafeId, tableId, token, {
      menuItemId: item.id,
      name: item.name,
      price: item.price,
      qty: 1,
    });
  };

  const handlePlaceOrder = async () => {
    setPlacing(true);
    await placeOrder(cafeId, tableId, token, cart);
    setPlacing(false);
    setCartOpen(false);
  };

  const renderItemRow = (item: MenuItem) => (
    <div key={item.id} className="flex items-center gap-3 py-4">
      <div className="h-14 w-14 shrink-0 overflow-hidden rounded-2xl bg-surface">
        {item.imageUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={item.imageUrl} alt={item.name} className="h-full w-full object-cover" />
        ) : (
          <div className="flex h-full w-full items-center justify-center">
            <ForkKnife size={20} weight="thin" className="text-inkFaint" />
          </div>
        )}
      </div>

      <div className="min-w-0 flex-1">
        <p className="font-medium">{item.name}</p>
        {item.description && (
          <p className="mt-0.5 truncate text-[13px] text-inkFaint">{item.description}</p>
        )}
      </div>

      <span className="tabular shrink-0 font-semibold text-moss">₹{item.price}</span>

      <button
        disabled={!item.isAvailable}
        onClick={() => handleAdd(item)}
        className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full ${
          item.isAvailable ? "bg-moss text-paper" : "bg-rule text-inkFaint"
        } disabled:cursor-not-allowed`}
        aria-label={item.isAvailable ? `Add ${item.name}` : `${item.name} sold out`}
      >
        <Plus size={16} weight="bold" />
      </button>
    </div>
  );

  return (
    <div className="mx-auto max-w-md pb-28">
      <header className="px-6 pb-4 pt-10">
        <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-inkFaint">
          Table {tableId.replace("table-", "")}
        </p>
        <h1 className="mt-1 text-[26px] font-bold leading-tight">{cafeName}</h1>
      </header>

      {trackedItems.length > 0 && (
        <section className="px-6 pb-5">
          <div className="mb-3 flex items-center justify-between">
            <p className="text-[13px] font-semibold uppercase tracking-[0.1em] text-inkFaint">
              Your order
            </p>
            <span className="tabular text-[13px] font-semibold text-moss">
              ₹{trackedTotal}
            </span>
          </div>
          <div className="space-y-2">
            {trackedItems.map((item) => (
              <div key={item.id} className="flex items-center justify-between">
                <span className="text-sm">
                  {item.qty} × {item.name}
                </span>
                <span className="flex items-center gap-1.5 rounded-full bg-surface px-2.5 py-1 text-xs font-medium">
                  {item.status === "pending" && (
                    <>
                      <Clock size={13} weight="thin" className="text-inkFaint" />
                      <span className="text-inkFaint">Received</span>
                    </>
                  )}
                  {item.status === "preparing" && (
                    <>
                      <CookingPot size={13} weight="thin" className="text-moss" />
                      <span className="text-moss">Preparing</span>
                    </>
                  )}
                  {item.status === "done" && (
                    <>
                      <CheckCircle size={13} weight="fill" className="text-moss" />
                      <span className="text-moss">Ready</span>
                    </>
                  )}
                </span>
              </div>
            ))}
          </div>
        </section>
      )}

      <div className="sticky top-0 z-10 bg-paper/95 px-6 pb-3 pt-2 backdrop-blur-sm">
        <div className="mb-3 flex items-center gap-2 rounded-full bg-surface px-4 py-3">
          <MagnifyingGlass size={17} weight="regular" className="text-inkFaint shrink-0" />
          <input
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search the menu"
            className="w-full bg-transparent text-sm outline-none placeholder:text-inkFaint"
          />
          {searchQuery && (
            <button onClick={() => setSearchQuery("")} className="shrink-0 text-inkFaint">
              <X size={15} weight="bold" />
            </button>
          )}
        </div>

        {!searching && (
          <div className="no-scrollbar flex gap-5 overflow-x-auto border-b border-rule">
            {categories.map((cat) => {
              const active = cat === activeCategory;
              return (
                <button
                  key={cat}
                  onClick={() => setActiveCategory(cat)}
                  className={`shrink-0 whitespace-nowrap pb-2.5 text-[13px] font-medium transition-colors ${
                    active
                      ? "border-b-2 border-ink text-ink"
                      : "border-b-2 border-transparent text-inkFaint"
                  }`}
                >
                  {cat}
                </button>
              );
            })}
          </div>
        )}
      </div>

      {displayItems.length === 0 ? (
        <div className="px-6 py-16 text-center">
          <p className="text-sm text-inkFaint">
            {searching ? `Nothing matches "${searchQuery.trim()}"` : "No items in this category yet"}
          </p>
        </div>
      ) : searching ? (
        <section className="px-6 py-2">{displayItems.map(renderItemRow)}</section>
      ) : activeCategory !== "All" ? (
        <section className="px-6 py-2">{displayItems.map(renderItemRow)}</section>
      ) : (
        categories
          .filter((c) => c !== "All")
          .map((category) => {
            const items = displayItems.filter((m) => m.category === category);
            if (items.length === 0) return null;
            return (
              <section key={category} className="px-6 py-5">
                <h2 className="mb-1 text-[13px] font-semibold uppercase tracking-[0.1em] text-inkFaint">
                  {category}
                </h2>
                <div>{items.map(renderItemRow)}</div>
              </section>
            );
          })
      )}

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
          className="fixed inset-0 z-20 flex items-end bg-ink/50"
          onClick={() => setCartOpen(false)}
        >
          <div
            className="w-full max-w-md mx-auto max-h-[75vh] overflow-y-auto rounded-t-[28px] bg-paper px-6 pb-8 pt-6"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="mx-auto mb-5 h-1 w-10 rounded-full bg-rule" />
            <p className="mb-4 text-[15px] font-semibold uppercase tracking-[0.08em] text-inkFaint">
              Your order
            </p>
            {cart.map((item) => (
              <div key={item.menuItemId} className="flex items-center justify-between py-3">
                <div>
                  <p className="font-medium">{item.name}</p>
                  <p className="tabular text-[13px] text-inkFaint">
                    ₹{item.price} × {item.qty}
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <button
                    onClick={() => updateQty(cafeId, tableId, token, item.menuItemId, item.qty - 1)}
                    className="flex h-7 w-7 items-center justify-center rounded-full bg-surface"
                  >
                    <Minus size={13} weight="bold" />
                  </button>
                  <span className="tabular w-4 text-center text-sm">{item.qty}</span>
                  <button
                    onClick={() => updateQty(cafeId, tableId, token, item.menuItemId, item.qty + 1)}
                    className="flex h-7 w-7 items-center justify-center rounded-full bg-surface"
                  >
                    <Plus size={13} weight="bold" />
                  </button>
                </div>
              </div>
            ))}
            <div className="mt-4 flex justify-between border-t border-dashed border-rule pt-4">
              <span className="font-semibold">Total</span>
              <span className="tabular font-semibold text-moss">₹{cartTotal}</span>
            </div>
            <button
              onClick={handlePlaceOrder}
              disabled={placing}
              className="mt-5 w-full rounded-full bg-moss py-4 text-sm font-semibold text-paper disabled:opacity-60"
            >
              {placing ? "Placing order…" : "Place order"}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}