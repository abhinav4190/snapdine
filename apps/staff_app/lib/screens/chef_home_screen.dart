import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/order_item_model.dart';
import 'package:staff_app/models/staff_model.dart';
import 'package:staff_app/providers/auth_provider.dart';
import 'package:staff_app/providers/kds_providers.dart';
import 'package:staff_app/theme/app_colors.dart';

class ChefHomeScreen extends ConsumerWidget {
  final StaffModel staff;
  const ChefHomeScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(pendingItemsProvider(staff.cafeId));
    return Scaffold(
      appBar: AppBar(
        title: Text('Kitchen: ${staff.cafeId}'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.signOut, size: 20),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsThin.checkCircle,
                    size: 32,
                    color: AppColors.sage,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'All caught up',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final byTable = <String, List<OrderItemModel>>{};
          for (final item in items) {
            byTable.putIfAbsent(item.tableId, () => []).add(item);
          }
          final tableIds = byTable.keys.toList()..sort();

          return ListView.builder(
            itemCount: tableIds.length,
            itemBuilder: (context, index) {
              final tableId = tableIds[index];
              final tableItems = byTable[tableId]!;
              final tableLabel = tableId.replaceAll('table-', 'Table ');

              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ).copyWith(bottom: 16, top: 5),
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tableLabel,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...tableItems.map(
                      (item) => _ItemRow(item: item, cafeId: staff.cafeId),
                    ),
                  ],
                ),
              );
            },
          );
        },
        error: (error, _) => Center(
          child: Text(
            'Could not load orders $error',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.rosewood,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _ItemRow extends ConsumerWidget {
  final OrderItemModel item;
  final String cafeId;
  const _ItemRow({super.key, required this.item, required this.cafeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = item.status == ItemStatus.pending;
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item.qty} × ${item.name}',
              style: TextStyle(color: AppColors.crema, fontSize: 14.5),
            ),
          ),
          GestureDetector(
            onTap: () {
              final service = ref.read(kdsServiceProvider);
              if (isPending) {
                service.markPreparing(cafeId, item.orderId, item.id);
              } else {
                service.markDone(cafeId, item.orderId, item.id);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPending
                    ? AppColors.surfaceHigh
                    : AppColors.rosewood.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPending ? 'Start' : 'Done',
                style: TextStyle(
                  color: isPending ? AppColors.muted : AppColors.rosewood,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
