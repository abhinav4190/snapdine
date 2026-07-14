enum TableStatus { available, occupied }

TableStatus tableStatusFromString(String value) {
  return value == 'occupied' ? TableStatus.occupied : TableStatus.available;
}

class TableModel {
  final String id;
  final int tableNumber;
  final TableStatus status;
  final String currentToken;
  final DateTime? sessionStartedAt;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.currentToken,
    required this.sessionStartedAt,
  });

  factory TableModel.fromMap(String id, Map<String, dynamic> data) {
    return TableModel(
      id: id,
      tableNumber: data['tableNumber'] as int,
      status: tableStatusFromString(data['status'] as String),
      currentToken: data['currentToken'],
      sessionStartedAt: data['sessionStartedAt'] != null
          ? (data['sessionStartedAt']).toDate()
          : null,
    );
  }
}
