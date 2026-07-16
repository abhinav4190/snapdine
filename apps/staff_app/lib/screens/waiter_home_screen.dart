import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/staff_model.dart';
import 'package:staff_app/models/table_model.dart';
import 'package:staff_app/providers/auth_provider.dart';
import 'package:staff_app/providers/billing_providers.dart';
import 'package:staff_app/providers/table_providers.dart';
import 'package:staff_app/screens/table_detail_screen.dart';
import 'package:staff_app/screens/table_list_screen.dart';
import 'package:staff_app/theme/app_colors.dart';

class WaiterHomeScreen extends ConsumerWidget {
  final StaffModel staff;
  const WaiterHomeScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tableStreamProvider(staff.cafeId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Hey, ${staff.name}'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.signOut, size: 20),
            onPressed: () => ref.read(authServiceProvider).signOut(),

          ),
        ],
        scrolledUnderElevation: 0,
        
      ),
      body: Column(
        children: [
          tablesAsync.when(
            data: (tables) {
              final occupied = tables.where((t) => t.status == TableStatus.occupied).toList();
              if (occupied.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active tables',
                        style: TextStyle(
                            color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 10),
                    ...occupied.map((table) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TableDetailScreen(cafeId: staff.cafeId, table: table),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Text('Table ${table.tableNumber}',
                                      style: const TextStyle(color: AppColors.crema)),
                                  const Spacer(),
                                  _InlineBillTotal(cafeId: staff.cafeId, tableId: table.id),
                                ],
                              ),
                            ),
                          ),
                        )),
                    const Divider(color: AppColors.surfaceHigh, height: 28),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(child: TableListScreen(staff: staff)),
        ],
      ),
    );
  }
}

class _InlineBillTotal extends ConsumerWidget {
  final String cafeId;
  final String tableId;
  const _InlineBillTotal({required this.cafeId, required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingAsync = ref.watch(billingStramProvider(BillingArgs(cafeId: cafeId, tableId: tableId)));
    return billingAsync.when(
      data: (snapshot) => Text('₹${snapshot.subtotal.toStringAsFixed(0)}',
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
      loading: () => const Text('…', style: TextStyle(color: AppColors.gold)),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}