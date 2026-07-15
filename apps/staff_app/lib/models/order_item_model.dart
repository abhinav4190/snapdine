enum ItemStatus { pending, preparing, done }

ItemStatus itemStatusFromString(String value) {
  switch (value) {
    case 'preparing':
      return ItemStatus.preparing;
    case 'done':
      return ItemStatus.done;
    default:
      return ItemStatus.pending;
  }
}

class OrderItemModel {
  final String id;
  final String orderId;
  final String tableId;
  final String name;
  final int qty;
  final ItemStatus status;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.tableId,
    required this.name,
    required this.qty,
    required this.status,
  });
}
