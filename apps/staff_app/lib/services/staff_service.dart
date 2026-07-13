import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staff_app/models/staff_model.dart';

class StaffService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<StaffModel?> fetchStaffProfile(String uid) async {
    final indexDoc = await _db.collection('staffIndex').doc(uid).get();
    if (!indexDoc.exists) return null;

    final cafeId = indexDoc.data()!['cafeId'] as String;

    final staffDoc = await _db
        .collection('cafes')
        .doc(cafeId)
        .collection('staff')
        .doc(uid)
        .get();

    if (!staffDoc.exists) return null;

    return StaffModel.fromMap(uid: uid, cafeId: cafeId, data: staffDoc.data()!);
  }
}
