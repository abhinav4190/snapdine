import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/menu_item_model.dart';
import 'package:staff_app/providers/menu_providers.dart';
import 'package:staff_app/screens/menu_item_form_screen.dart';
import 'package:staff_app/services/menu_ocr_screen.dart';
import 'package:staff_app/theme/app_colors.dart';

class MenuListScreen extends ConsumerWidget {
  final String cafeId;
  const MenuListScreen({super.key, required this.cafeId});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MenuItemModel item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Remove item?', style: TextStyle(color: AppColors.crema)),
        content: Text(
          '${item.name} will be removed from the menu',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove', style: TextStyle(color: AppColors.rosewood)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(menuServiceProvider).deleteItem(cafeId, item.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuStreamProvider(cafeId));
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text('Menu'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MenuOcrScreen(cafeId: cafeId)),
            ),
            icon: Icon(
              PhosphorIconsThin.sparkle,
              size: 22,
              color: AppColors.gold,
            ),
            tooltip: 'Scan menu with AI',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuItemFormScreen(cafeId: cafeId)),
        ),
        child: Icon(PhosphorIconsBold.plus, color: AppColors.ink),
      ),
      body: menuAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsThin.forkKnife,
                      size: 30,
                      color: AppColors.muted,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No menu items yet',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          final byCategory = <String, List<MenuItemModel>>{};
          for (final item in items) {
            byCategory.putIfAbsent(item.category, () => []).add(item);
          }
          return SafeArea(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: byCategory.entries.map((entery) {
                return Padding(
                  padding: EdgeInsetsGeometry.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entery.key,
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...entery.value.map(
                        (item) => Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            await _confirmDelete(context, ref, item);
                            return false;
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                          ),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MenuItemFormScreen(
                                  cafeId: cafeId,
                                  existing: item,
                                ),
                              ),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            color: AppColors.crema,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '₹${item.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: item.isAvailable,
                                    activeColor: AppColors.gold,
                                    onChanged: (v) => ref
                                        .read(menuServiceProvider)
                                        .toggleAvailability(cafeId, item.id, v),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
        error: (_, __) => Center(child: Text('Could not load menu')),
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
