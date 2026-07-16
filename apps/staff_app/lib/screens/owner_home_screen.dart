import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/staff_model.dart';
import 'package:staff_app/models/table_model.dart';
import 'package:staff_app/providers/auth_provider.dart';
import 'package:staff_app/providers/billing_providers.dart';
import 'package:staff_app/providers/table_providers.dart';
import 'package:staff_app/screens/menu_list_screen.dart';
import 'package:staff_app/screens/profile_screen.dart';
import 'package:staff_app/screens/table_detail_screen.dart';
import 'package:staff_app/screens/table_list_screen.dart';
import 'package:staff_app/theme/app_colors.dart';

class OwnerHomeScreen extends ConsumerWidget {
  final StaffModel staff;
  const OwnerHomeScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hey, ${staff.name}"),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.signOut, size: 20),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer(
              builder: (context, ref, _) {
                final tableAsunc = ref.watch(tableStreamProvider(staff.cafeId));
                return tableAsunc.when(
                  data: (tables) {
                    final occupied = tables
                        .where((t) => t.status == TableStatus.occupied)
                        .toList();
                    if (occupied.isEmpty) return SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Tables',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10),
                          ...occupied.map(
                            (table) => Padding(
                              padding: EdgeInsetsGeometry.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TableDetailScreen(
                                      cafeId: staff.cafeId,
                                      table: table,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Table ${table.tableNumber}',
                                        style: TextStyle(
                                          color: AppColors.crema,
                                        ),
                                      ),
                                      Spacer(),
                                      _InlineBillTotal(
                                        cafeId: staff.cafeId,
                                        tableId: table.id,
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
                  },
                  error: (_, __) => SizedBox.shrink(),
                  loading: () => SizedBox.shrink(),
                );
              },
            ),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TableListScreen(staff: staff),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsThin.squaresFour,
                      size: 26,
                      color: AppColors.gold,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage tables',
                            style: TextStyle(
                              color: AppColors.crema,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Add tables, see billing, take order',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MenuListScreen(cafeId: staff.cafeId),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsThin.forkKnife,
                      size: 26,
                      color: AppColors.gold,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manage menu',
                            style: TextStyle(
                              color: AppColors.crema,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Add items, edit prices, toogle stock',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(staff: staff)),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsThin.userGear,
                      size: 26,
                      color: AppColors.gold,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile & Staff',
                            style: TextStyle(
                              color: AppColors.crema,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Cafe settings, manage waiters & chefs',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(PhosphorIconsRegular.caretRight, size: 18, color: AppColors.muted,)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineBillTotal extends ConsumerWidget {
  final String cafeId;
  final String tableId;
  const _InlineBillTotal({
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
        style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
      ),
      error: (_, __) => SizedBox.shrink(),
      loading: () => Text('...', style: TextStyle(color: AppColors.gold)),
    );
  }
}
