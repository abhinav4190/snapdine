import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staff_app/models/menu_item_model.dart';

class MenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _menuRef(String cafeId) =>
      FirebaseFirestore.instance
          .collection('cafes')
          .doc(cafeId)
          .collection('menu');

  Stream<List<MenuItemModel>> streamMenu(String cafeId) {
    return _menuRef(cafeId).snapshots().map(
      (snap) =>
          snap.docs.map((d) => MenuItemModel.fromMap(d.id, d.data())).toList(),
    );
  }

  Future<void> addItem(String cafeId, MenuItemModel item) {
    return _menuRef(cafeId).add(item.toMap());
  }

  Future<void> addItemsBatch(String cafeId, List<MenuItemModel> items) async {
    final batch = _db.batch();
    for (final item in items) {
      batch.set(_menuRef(cafeId).doc(), item.toMap());
    }
    await batch.commit();
  }

  Future<void> updateItem(String cafeId, MenuItemModel item) {
    return _menuRef(cafeId).doc(item.id).update(item.toMap());
  }

  Future<void> toggleAvailability(
    String cafeId,
    String itemId,
    bool isAvailable,
  ) {
    return _menuRef(cafeId).doc(itemId).update({'isAvailable': isAvailable});
  }

  Future<void> deleteItem(String cafeId, String itemId) {
    return _menuRef(cafeId).doc(itemId).delete();
  }
}
