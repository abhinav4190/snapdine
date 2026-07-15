import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/models/menu_item_model.dart';
import 'package:staff_app/services/menu_service.dart';

final menuServiceProvider = Provider<MenuService>((ref) => MenuService());

final menuStreamProvider = StreamProvider.family<List<MenuItemModel>, String>((
  ref,
  cafeId,
) {
  return ref.watch(menuServiceProvider).streamMenu(cafeId);
});
