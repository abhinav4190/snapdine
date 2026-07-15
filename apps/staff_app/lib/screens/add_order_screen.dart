import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/menu_item_model.dart';
import 'package:staff_app/providers/menu_providers.dart';
import 'package:staff_app/providers/staff_order_providers.dart';
import 'package:staff_app/services/staff_order_service.dart';
import 'package:staff_app/theme/app_colors.dart';

class AddOrderScreen extends ConsumerStatefulWidget {
  final String cafeId;
  final String tableId;
  const AddOrderScreen({
    super.key,
    required this.cafeId,
    required this.tableId,
  });

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final Map<String, int> _qty = {};
  bool _placing = false;

  int get _totalCount => _qty.values.fold(0, (a, b) => a + b);

  Future<void> _placeOrder(List<MenuItemModel> menu) async {
    final lines = _qty.entries.where((element) => element.value > 0).map((e) {
      final item = menu.firstWhere((m) => m.id == e.key);
      return StaffOrderLine(
        menuItemId: item.id,
        name: item.name,
        price: item.price,
        qty: e.value,
      );
    }).toList();

    if (lines.isEmpty) return;

    setState(() => _placing = true);

    await ref
        .read(staffOrderServiceProvider)
        .placeStaffOrder(widget.cafeId, widget.tableId, lines);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuStreamProvider(widget.cafeId));
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Add order: ${widget.tableId.replaceAll('table-', 'Table ')}',
          
        ),
      ),
      body: menuAsync.when(
        data: (menu) {
          final available = menu.where((m) => m.isAvailable).toList();
          final byCategory = <String, List<MenuItemModel>>{};
          for (final item in available) {
            byCategory.putIfAbsent(item.category, () => []).add(item);
          }
          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: byCategory.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...entry.value.map((item) {
                          final qty = _qty[item.id] ?? 0;
                          return Container(
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
                                        ),
                                      ),
                                      Text(
                                        '₹${item.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: qty > 0
                                      ? () => setState(
                                          () => _qty[item.id] = qty - 1,
                                        )
                                      : null,
                                  icon: Icon(
                                    PhosphorIconsBold.minusCircle,
                                    size: 22,
                                    color: AppColors.muted,
                                  ),
                                ),
                                SizedBox(
                                  width: 22,
                                  child: Text(
                                    '$qty',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.crema),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _qty[item.id] = qty + 1),
                                  icon: Icon(
                                    PhosphorIconsBold.plusCircle,
                                    size: 22,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (_totalCount > 0)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: ElevatedButton(
                    onPressed: _placing ? null : () => _placeOrder(menu),
                    child: _placing
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.ink,
                            ),
                          )
                        : Text(
                            'Add $_totalCount item${_totalCount > 1 ? 's' : ''} to order',
                          ),
                  ),
                ),
            ],
          );
        },
        error: (e, __) => Center(child: Text('Could not load menu')),
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
