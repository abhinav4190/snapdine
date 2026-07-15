import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staff_app/models/bill_item_model.dart';

class BillingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<BillingSnapshot> streamBilling(String cafeId, String tableId) {
    late StreamController<BillingSnapshot> controller;
    final itemSubs = <String, StreamSubscription>{};
    final itemsByOrder = <String, List<BillItemModel>>{};
    StreamSubscription? ordersSub;

    void emit() {
      final all = <BillItemModel>[];
      itemsByOrder.forEach((_, list) => all.addAll(list));
      controller.add(
        BillingSnapshot(items: all, orderIds: itemsByOrder.keys.toList()),
      );
    }

    controller = StreamController<BillingSnapshot>.broadcast(
      onListen: () {
        ordersSub = _db
            .collection("cafes")
            .doc(cafeId)
            .collection("orders")
            .where("tableId", isEqualTo: tableId)
            .where("isPaid", isEqualTo: false)
            .snapshots()
            .listen((snap) {
              final currentIds = snap.docs.map((d) => d.id).toSet();

              itemSubs.keys.toList().forEach((orderId) {
                if (!currentIds.contains(orderId)) {
                  itemSubs[orderId]?.cancel();
                  itemSubs.remove(orderId);
                  itemsByOrder.remove(orderId);
                }
              });

              for (final doc in snap.docs) {
                if (itemSubs.containsKey(doc.id)) continue;
                final sub = _db
                    .collection('cafes')
                    .doc(cafeId)
                    .collection('orders')
                    .doc(doc.id)
                    .collection('items')
                    .snapshots()
                    .listen((itemsSnap) {
                      itemsByOrder[doc.id] = itemsSnap.docs.map((d) {
                        final data = d.data();
                        return BillItemModel(
                          name: data['name'] as String,
                          price: (data['price'] as num).toDouble(),
                          qty: data['qty'] as int,
                        );
                      }).toList();
                      emit();
                    });
                itemSubs[doc.id] = sub;
              }
              emit();
            });
      },
      onCancel: () {
        ordersSub?.cancel();
        for (final sub in itemSubs.values) {
          sub.cancel();
        }
      },
    );
    return controller.stream;
  }

  Future<void> markOrdersPaid(String cafeId, List<String> orderIds) async {
    final batch = _db.batch();
    for (final id in orderIds) {
      batch.update(
        _db.collection('cafes').doc(cafeId).collection('orders').doc(id),
        {'isPaid': true},
      );
    }
    await batch.commit();
  }
}
