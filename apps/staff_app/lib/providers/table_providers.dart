import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/models/table_model.dart';
import 'package:staff_app/services/table_service.dart';

final tableServiceProvider = Provider<TableService>((ref) => TableService());

final tableStreamProvider = StreamProvider.family<List<TableModel>, String>((
  ref,
  cafeId,
) {
  return ref.watch(tableServiceProvider).streamTables(cafeId);
});
