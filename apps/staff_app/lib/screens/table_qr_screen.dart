import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:staff_app/models/table_model.dart';
import 'package:staff_app/providers/table_providers.dart';
import 'package:staff_app/theme/app_colors.dart';

class TableQrScreen extends ConsumerStatefulWidget {
  final String cafeId;
  final TableModel table;

  const TableQrScreen({
    super.key,
    required this.cafeId,
    required this.table,
  });

  @override
  ConsumerState<TableQrScreen> createState() => _TableQrScreenState();
}

class _TableQrScreenState extends ConsumerState<TableQrScreen> {
  final GlobalKey _qrKey = GlobalKey();

  String get _qrUrl =>
      '${dotenv.env['CUSTOMER_WEB_URL']!}/order?cafeId=${widget.cafeId}&tableId=${widget.table.id}&token=${widget.table.currentToken}';

  Future<void> _downloadQr() async {
    try {
      final permission = await Permission.photos.request();

         if (permission.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission denied. Enable it from app settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
      return;
    }

      if (!permission.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied'),
          ),
        );
        return;
      }

      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 4);

      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name:
            "table_${widget.table.tableNumber}_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("QR Code downloaded successfully"),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Reset table?',
          style: TextStyle(color: AppColors.crema),
        ),
        content: const Text(
          'This clears the session and prints a new QR code. Old QR code will stop working.',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(tableServiceProvider)
          .resetTable(widget.cafeId, widget.table.id);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final table = widget.table;

    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${table.tableNumber}'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                         Text(
                      "SNAPDINE",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      "Table ${table.tableNumber}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 20),

                    QrImageView(
                      data: _qrUrl,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Scan to Order",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "No App Required • No Login Required",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _downloadQr,
              icon: const Icon(Icons.download),
              label: const Text("Download QR"),
            ),

            const SizedBox(height: 20),

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
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            TextButton.icon(
              onPressed: _confirmReset,
              icon: Icon(
                PhosphorIconsThin.arrowsClockwise,
                size: 18,
                color: AppColors.gold,
              ),
              label: const Text(
                'Reset session',
                style: TextStyle(color: AppColors.gold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}