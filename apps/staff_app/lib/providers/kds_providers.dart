import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/models/order_item_model.dart';
import 'package:staff_app/services/kds_service.dart';

final kdsServiceProvider = Provider<KdsService>((ref) => KdsService());

final pendingItemsProvider =
    StreamProvider.family<List<OrderItemModel>, String>((ref, param) {
      return ref.watch(kdsServiceProvider).streamPendingItems(param);
    });
