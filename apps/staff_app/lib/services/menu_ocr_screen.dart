import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/menu_item_model.dart';
import 'package:staff_app/providers/menu_providers.dart';
import 'package:staff_app/providers/ocr_providers.dart';
import 'package:staff_app/theme/app_colors.dart';

class MenuOcrScreen extends ConsumerStatefulWidget {
  final String cafeId;
  const MenuOcrScreen({super.key, required this.cafeId});

  @override
  ConsumerState<MenuOcrScreen> createState() => _MenuOcrScreenState();
}

class _MenuOcrScreenState extends ConsumerState<MenuOcrScreen> {
  bool _loading = false;
  List<MenuItemModel> _extracted = [];
  final Set<int> _selected = {};
  bool _saving = false;
  String? _error;

  Future<void> _pickAndScan(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _loading = true;
      _error = null;
      _extracted = [];
      _selected.clear();
    });

    try {
      final items = await ref
          .read(ocrServiceProvider)
          .extractMenuFromImage(File(picked.path));
      setState(() {
        _extracted = items;
        _selected.addAll(List.generate(items.length, (i) => i));
      });
    } catch (e) {
      setState(() => _error = 'Could not read this menu. Try a clearer photo. $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveSelected() async {
    final toSave = _selected.map((i) => _extracted[i]).toList();
    if (toSave.isEmpty) return;
    setState(() => _saving = true);
    await ref.read(menuServiceProvider).addItemsBatch(widget.cafeId, toSave);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan menu with AI'),  scrolledUnderElevation: 0,
        elevation: 0,),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              ),
            )
          : _extracted.isEmpty
          ? _buildPickState()
          : _buildReviewtate(),
    );
  }

  Widget _buildPickState() {
    return Center(
      child: Padding(
        padding: EdgeInsetsGeometry.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsThin.sparkle, size: 36, color: AppColors.gold),
            const SizedBox(height: 16),
            Text(
              'Take a photo of your physical menu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.crema,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'AI will extract items, price, and categories for you to review before saving.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            if (_error != null) ...[
              SizedBox(height: 14),
              Text(
                _error!,
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ],
            SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _pickAndScan(ImageSource.camera),
              label: Text('Take photo'),
              icon: Icon(PhosphorIconsBold.camera, size: 18),
            ),
            SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _pickAndScan(ImageSource.gallery),
              label: Text('Choose from gallery'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(52),
                side: BorderSide.none,
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.crema,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(PhosphorIconsThin.image, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewtate() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Text(
                '${_extracted.length} items found',
                style: TextStyle(
                  color: AppColors.crema,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _extracted = [];
                  _selected.clear();
                }),
                child: Text('Retake', style: TextStyle(color: AppColors.muted)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: _extracted.length,
            itemBuilder: (context, index) {
              final item = _extracted[index];
              final selected = _selected.contains(index);
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: selected,
                      activeColor: AppColors.gold,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(index);
                          } else {
                            _selected.remove(index);
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name.isEmpty ? 'no name' : item.name,
                            style: TextStyle(
                              color: AppColors.crema,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${item.category} · ₹${item.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsetsGeometry.fromLTRB(20, 8, 20, 20),
          child: ElevatedButton(
            onPressed: (_saving || _selected.isEmpty) ? null : _saveSelected,
            child: _saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.ink,
                    ),
                  )
                : Text(
                    'Add ${_selected.length} item${_selected.length == 1 ? '' : 's'} to menu',
                  ),
          ),
        ),
      ],
    );
  }
}
