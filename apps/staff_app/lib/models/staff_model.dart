import 'package:flutter/foundation.dart';

enum StaffRole { owner, waiter, chef }

StaffRole staffRoleFromString(String value) {
  switch (value) {
    case 'owner':
      return StaffRole.owner;
    case 'waiter':
      return StaffRole.waiter;
    case 'chef':
      return StaffRole.chef;
    default:
      throw ArgumentError('Unknown stff $value');
  }
}

class StaffModel {
  final String uid;
  final String cafeId;
  final StaffRole role;
  final String name;
  final String phone;

  StaffModel({
    required this.uid,
    required this.cafeId,
    required this.role,
    required this.name,
    required this.phone,
  });

  factory StaffModel.fromMap({
    required String uid,
    required String cafeId,
    required Map<String, dynamic> data,
  }) {
    return StaffModel(
      uid: uid,
      cafeId: cafeId,
      role: staffRoleFromString(data['role'] as String),
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }
}
