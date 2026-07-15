import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/services/staff_order_service.dart';

final staffOrderServiceProvider = Provider<StaffOrderService>((ref) => StaffOrderService(),);