import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staff_app/models/cafe_config_model.dart';

class CafeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<CafeConfigModel> fetchConfig(String cafeId) async {
    final snap = await _db.collection('cafes').doc(cafeId).get();
    return CafeConfigModel.fromMap(snap.data() ?? {});
  }

  Future<Map<String, bool>> fetchOnboardingStatus(String cafeId) async {
    final snap = await _db.collection('cafes').doc(cafeId).get();
    final data = snap.data() ?? {};
    return {
      'basicInfoDone': data['baiscInfoDone'] as bool? ?? false,
      'onboarded': data['onboarded'] as bool? ?? false,
    };
  }

  Future<void> saveOnboardingBasicInfo(
    String cafeId, {
    required String name,
    required double gstPercent,
    required double serviceChargePercent,
  }) async {
    await _db.collection('cafes').doc(cafeId).update({
      'name': name,
      'config.gstPercent': gstPercent,
      'config.serviceChargePercent': serviceChargePercent,
      'baiscInfoDone': true,
    });
  }

  Future<void> completeOnboarding(String cafeId) async {
    await _db.collection('cafes').doc(cafeId).update({'onboarded': true});
  }

  Future<void> updateCafeConfig(
    String cafeId, {
    required String name,
    required double gstPercent,
    required double serviceChargePercent,
  }) async {
    await _db.collection('cafes').doc(cafeId).update({
      'name': name,
      'config.gstPercent': gstPercent,
      'config.serviceChargePercent': serviceChargePercent,
    });
  }
}
