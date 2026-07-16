import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/staff_model.dart';
import 'package:staff_app/models/table_model.dart';
import 'package:staff_app/providers/billing_providers.dart';
import 'package:staff_app/providers/table_providers.dart';
import 'package:staff_app/screens/billing_screen.dart';
import 'package:staff_app/screens/table_detail_screen.dart';
import 'package:staff_app/screens/table_qr_screen.dart';
import 'package:staff_app/theme/app_colors.dart';

class TableListScreen extends ConsumerWidget {
  final StaffModel staff;
  final bool embedded;
  const TableListScreen({
    super.key,
    required this.staff,
    this.embedded = false,
  });

  Future<void> _showAddTableDialog(
    BuildContext context,
    WidgetRef ref,
    int nextNumber,
  ) async {
    final controller = TextEditingController(text: nextNumber.toString());
    final confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Add table', style: TextStyle(color: AppColors.crema)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: AppColors.crema),
          decoration: InputDecoration(hintText: 'Table number'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Add', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final number = int.tryParse(controller.text.trim());
      if (number != null) {
        await ref.read(tableServiceProvider).addTable(staff.cafeId, number);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tableStreamProvider(staff.cafeId));

    final body = tablesAsync.when(
      data: (tables) {
        if (tables.isEmpty) {
          return Center(
            child: Text(
              staff.role == StaffRole.owner
                  ? "No tables yet. Tap + to add one."
                  : "No tables set up yet",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return GridView.builder(
          padding: EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.1,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final table = tables[index];
            final isOccupied = table.status == TableStatus.occupied;

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TableDetailScreen(cafeId: staff.cafeId, table: table),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      PhosphorIconsThin.squaresFour,
                      size: 26,
                      color: isOccupied ? AppColors.rosewood : AppColors.sage,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table ${table.tableNumber}',
                          style: TextStyle(
                            color: AppColors.crema,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (isOccupied)
                          _LiveBillLable(
                            cafeId: staff.cafeId,
                            tableId: table.id,
                          )
                        else
                          Text(
                            'Available',
                            style: TextStyle(
                              color: AppColors.sage,
                              fontSize: 12.5,
                            ),
                          ),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Icon(
                    //       PhosphorIconsThin.squaresFour,
                    //       size: 26,
                    //       color: isOccupied
                    //           ? AppColors.rosewood
                    //           : AppColors.sage,
                    //     ),
                    //     if (isOccupied)
                    //       GestureDetector(
                    //         onTap: () => Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (_) => BillingScreen(
                    //               cafeId: staff.cafeId,
                    //               tablleId: table.id,
                    //             ),
                    //           ),
                    //         ),
                    //         child: const Icon(
                    //           PhosphorIconsThin.receipt,
                    //           size: 20,
                    //           color: AppColors.gold,
                    //         ),
                    //       ),
                    //   ],
                    // ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       'Table ${table.tableNumber}',
                    //       style: const TextStyle(
                    //         color: AppColors.crema,
                    //         fontWeight: FontWeight.w600,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //     const SizedBox(height: 4),
                    //     Text(
                    //       isOccupied ? 'Occupied' : 'Available',
                    //       style: TextStyle(
                    //         color: isOccupied
                    //             ? AppColors.rosewood
                    //             : AppColors.sage,
                    //         fontSize: 12.5,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            );
          },
        );
      },
      error: (error, _) => Center(
        child: Text(
          'Could not load tables',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      loading: () => Center(
        child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
      ),
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tables'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: staff.role == StaffRole.owner
          ? FloatingActionButton(
              onPressed: () {
                final currentCount = tablesAsync.value?.length ?? 0;
                _showAddTableDialog(context, ref, currentCount + 1);
              },
              child: Icon(PhosphorIconsBold.plus, color: AppColors.ink),
            )
          : null,
      body: body,
    );
  }
}

class _LiveBillLable extends ConsumerWidget {
  final String cafeId;
  final String tableId;
  const _LiveBillLable({
    super.key,
    required this.cafeId,
    required this.tableId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingAsync = ref.watch(
      billingStramProvider(BillingArgs(cafeId: cafeId, tableId: tableId)),
    );
    return billingAsync.when(
      data: (snap) => Text(
        '₹${snap.subtotal.toStringAsFixed(0)}',
        style: TextStyle(
          color: AppColors.rosewood,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      error: (e, _) => Text(
        'Occupied',
        style: TextStyle(color: AppColors.rosewood, fontSize: 12.5),
      ),
      loading: () => Text(
        '...',
        style: TextStyle(color: AppColors.rosewood, fontSize: 12.5),
      ),
    );
  }
}
