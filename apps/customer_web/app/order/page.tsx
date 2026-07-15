import { Suspense } from "react";
import OrderClient from "./order-client";

export default function OrderPage(){
    return (
        <Suspense fallback={<div className="p-8 text-center text-sm text-neutral-500">Loading...</div>}>
            <OrderClient/>
        </Suspense>
    );
}