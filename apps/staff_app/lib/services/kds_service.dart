import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:staff_app/models/order_item_model.dart';

class KdsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<OrderItemModel>> streamPendingItems(String cafeId) {
    return _db
        .collectionGroup('items')
        .where('cafeId', isEqualTo: cafeId)
        .where('status', whereIn: ['pending', 'preparing'])
        .orderBy('addedAt')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return OrderItemModel(
              id: d.id,
              orderId: d.reference.parent.parent!.id,
              tableId: data['tableId'] as String? ?? '',
              name: data['name'] as String,
              qty: data['qty'] as int,
              status: itemStatusFromString(data['status'] as String),
            );
          }).toList(),
        );
  }

  Future<void> markPreparing(String cafeId, String orderId, String itemId) {
    return _itemRef(cafeId, orderId, itemId).update({'status': 'preparing'});
  }

  Future<void> markDone(String cafeId, String orderId, String itemId) {
    return _itemRef(cafeId, orderId, itemId).update({'status': 'done'});
  }

  DocumentReference<Map<String, dynamic>> _itemRef(
    String cafeId,
    String orderId,
    String itemId,
  ) {
    return _db
        .collection('cafes')
        .doc(cafeId)
        .collection('orders')
        .doc(orderId)
        .collection('items')
        .doc(itemId);
  }
}
