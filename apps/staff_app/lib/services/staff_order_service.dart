import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class StaffOrderLine {
  final String menuItemId;
  final String name;
  final double price;
  final int qty;

  StaffOrderLine({required this.menuItemId, required this.name, required this.price, required this.qty});
}

class StaffOrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> placeStaffOrder(
    String cafeId,
    String tableId,
    List<StaffOrderLine> lines,
  ) async{
    final orderRef = await _db.collection('cafes').doc(cafeId).collection('orders').add({
      'tableId': tableId,
      'createdBy': "staff",
      'isPaid': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final batch = _db.batch();

    for (final line in lines){
      final itemRef = orderRef.collection('items').doc();
      batch.set(itemRef, {
        'cafeId': cafeId,
        'tableId': tableId,
        'menuItemId': line.menuItemId,
        'name': line.name,
        'price': line.price,
        'qty': line.qty,
        'status': 'pending',
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    await _db.collection('cafes').doc(cafeId).collection('tables').doc(tableId).update({
      'status': 'occupied',
      'sessionStartedAt': FieldValue.serverTimestamp(),
    });
    
  }
}