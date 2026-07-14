import { doc, getDoc } from "firebase/firestore";
import { db } from "./firebase";

export interface CafeConfig{
    name: string;
    themeColor: string;
    gstPercent: number;
    serviceChargePercent: number;
}

export async function verifyTable(cafeID: string, tableId: string, token: string) {
    const cafeSnap = await getDoc(doc(db, "cafes", cafeID));

    if(!cafeSnap.exists()) return {valid: false as const, reason: "cafe-not-found"};

    const tableSnap = await getDoc(doc(db, "cafes", cafeID, "tables", tableId));
    if(!tableSnap.exists()) return {valid: false as const, reason: "table_not_found"};

    const tableData = tableSnap.data();

    if(tableData.currentToken !== token){
        return {valid: false as const, reason: "token-mismatch"};
    }
    const cafeData = cafeSnap.data();

    return{
        valid: true as const,
        cafeName: cafeData.name as string,
        config: cafeData.config as CafeConfig,
    };
    
}