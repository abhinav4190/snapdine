import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staff_app/models/cafe_config_model.dart';

class CafeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<CafeConfigModel> fetchConfig(String cafeId) async {
    final snap = await _db.collection('cafes').doc(cafeId).get();
    return CafeConfigModel.fromMap(snap.data() ?? {});
  }
}
