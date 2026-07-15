import 'package:flutter/gestures.dart';

class BillItemModel {
  final String name;
  final double price;
  final int qty;

  BillItemModel({required this.name, required this.price, required this.qty});
}

class BillingSnapshot {
  final List<BillItemModel> items;
  final List<String> orderIds;

  BillingSnapshot({required this.items, required this.orderIds});

  double get subtotal => items.fold(0, (sum, i) => sum + i.price * i.qty);

  List<BillItemModel> get grouped {
    final Map<String, BillItemModel> map = {};
    for (final item in items) {
      final key = '${item.name}_${item.price}';
      if (map.containsKey(key)) {
        final existing = map[key]!;
        map[key] = BillItemModel(
          name: existing.name,
          price: existing.price,
          qty: existing.qty + item.qty,
        );
      } else{
        map[key] = item;
      }
    }
    return map.values.toList();
  }
}
