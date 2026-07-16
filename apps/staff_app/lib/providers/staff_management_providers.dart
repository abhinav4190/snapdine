import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/services/staff_service.dart';

final staffListStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, cafeId){
return StaffService().streamStaffList(cafeId);
});

final functionsProvider = Provider<FirebaseFunctions>((ref)=> FirebaseFunctions.instance);