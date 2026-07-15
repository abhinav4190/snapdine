import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/table_model.dart';
import 'package:staff_app/providers/billing_providers.dart';
import 'package:staff_app/screens/add_order_screen.dart';
import 'package:staff_app/screens/billing_screen.dart';
import 'package:staff_app/screens/table_qr_screen.dart';
import 'package:staff_app/theme/app_colors.dart';

class TableDetailScreen extends ConsumerWidget {
  final String cafeId;
  final TableModel table;
  const TableDetailScreen({
    super.key,
    required this.cafeId,
    required this.table,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOccupied = table.status == TableStatus.occupied;

    final billingAsync = isOccupied
        ? ref.watch(
            billingStramProvider(
              BillingArgs(cafeId: cafeId, tableId: table.id),
            ),
          )
        : null;
    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${table.tableNumber}'),

        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TableQrScreen(cafeId: cafeId, table: table),
              ),
            ),
            icon: Icon(PhosphorIconsThin.qrCode, size: 22),
            tooltip: 'View QR / Reset',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isOccupied) ...[
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(
                      PhosphorIconsThin.armchair,
                      size: 28,
                      color: AppColors.sage,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'This table is free',
                      style: TextStyle(color: AppColors.crema),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddOrderScreen(cafeId: cafeId, tableId: table.id),
                  ),
                ),
                child: Text('Take order'),
              ),
            ] else ...[
              billingAsync!.when(
                error: (_, __) => Text('Could not load bill'),
                loading: () => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold,
                  ),
                ),
                data: (snapshot) {
                  return Container(
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current bill',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '₹${snapshot.subtotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${snapshot.items.fold(0, (a, i) => a + i.qty)} items',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddOrderScreen(cafeId: cafeId, tableId: table.id),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(52),
                  side: BorderSide.none,
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.crema,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(14),
                  ),
                ),
                child: Text('Add more items'),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BillingScreen(cafeId: cafeId, tablleId: table.id),
                  ),
                ),
                child: Text('View full bill'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
