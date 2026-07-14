import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:staff_app/models/table_model.dart';
import 'package:staff_app/providers/table_providers.dart';
import 'package:staff_app/theme/app_colors.dart';

class TableQrScreen extends ConsumerWidget {
  final String cafeId;
  final TableModel table;
  const TableQrScreen({super.key, required this.cafeId, required this.table});

  String get _qrUrl =>
      '${dotenv.env['CUSTOMER_WEB_URL']!}/order?cafeId=$cafeId&tableId=${table.id}&token=${table.currentToken}';

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Reset table?', style: TextStyle(color: AppColors.crema)),
        content: Text(
          'This clears the session and prints a new QR code. The old QR code will stop working.',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Reset', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(tableServiceProvider).resetTable(cafeId, table.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Table ${table.tableNumber}')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.crema,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: _qrUrl,
                size: 220,
                backgroundColor: AppColors.crema,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.ink,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  table.status == TableStatus.occupied
                      ? PhosphorIconsFill.circle
                      : PhosphorIconsRegular.circle,
                  size: 10,
                  color: table.status == TableStatus.occupied
                      ? AppColors.rosewood
                      : AppColors.sage,
                ),
                const SizedBox(width: 8),
                Text(
                  table.status == TableStatus.occupied
                      ? 'Occupied'
                      : 'Available',
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 32),
            TextButton.icon(
              onPressed: () => _confirmReset(context, ref),
              label: Text(
                'Reset session',
                style: TextStyle(color: AppColors.gold),
              ),
              icon: Icon(
                PhosphorIconsThin.arrowsClockwise,
                size: 18,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
