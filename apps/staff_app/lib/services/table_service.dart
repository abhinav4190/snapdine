import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staff_app/models/table_model.dart';

class TableService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _generateToken() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }

  Stream<List<TableModel>> streamTables(String cafeId) {
    return _db
        .collection('cafes')
        .doc(cafeId)
        .collection('tables')
        .orderBy('tableNumber')
        .snapshots()
        .map(
          (snaps) => snaps.docs
              .map((a) => TableModel.fromMap(a.id, a.data()))
              .toList(),
        );
  }

  Future<void> addTable(String cafeId, int tableNumber) async {
    final tableId = 'table-$tableNumber';

    await _db
        .collection('cafes')
        .doc(cafeId)
        .collection('tables')
        .doc(tableId)
        .set(({
          'tableNumber': tableNumber,
          'status': 'available',
          'currentToken': _generateToken(),
          'sessionStartedAt': null,
        }));
  }

  Future<void> resetTable(String cafeId, String tableId) async {
    await _db
        .collection('cafes')
        .doc(cafeId)
        .collection('tables')
        .doc(tableId)
        .update({
          'status': 'available',
          'currentToken': _generateToken(),
          'sessionStartedAt': null,
        });
  }

  Future<void> markOccupied(String cafeId, String tableId) async{
    await _db.collection('cafes').doc(cafeId).collection('tables').doc(tableId).update({
      'status': 'occupied',
      'sessionStartedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTable(String cafeId, String tableId) async{
    await _db.collection('cafes').doc(cafeId).collection('tables').doc(tableId).delete();
  }
}
