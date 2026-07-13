import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/services/auth_service.dart';
import 'package:staff_app/services/staff_service.dart';
import 'package:staff_app/models/staff_model.dart';

final authServiceProvider = Provider((ref) {
  return AuthService();
});

final staffServiceProvider = Provider((ref) {
  return StaffService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChnges;
});

final staffProfileProvider = FutureProvider<StaffModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref.watch(staffServiceProvider).fetchStaffProfile(user.uid);
});