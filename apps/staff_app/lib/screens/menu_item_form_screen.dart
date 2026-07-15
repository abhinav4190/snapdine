import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/models/menu_item_model.dart';
import 'package:staff_app/providers/menu_providers.dart';
import 'package:staff_app/theme/app_colors.dart';

class MenuItemFormScreen extends ConsumerStatefulWidget {
  final String cafeId;
  final MenuItemModel? existing;
  const MenuItemFormScreen({super.key, required this.cafeId, this.existing});

  @override
  ConsumerState<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends ConsumerState<MenuItemFormScreen> {
  late final _nameController = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final _priceController = TextEditingController(
    text: widget.existing?.price.toStringAsFixed(0) ?? '',
  );
  late final _categoryController = TextEditingController(
    text: widget.existing?.category ?? '',
  );
  late final _descController = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late bool _isAvailable = widget.existing?.isAvailable ?? true;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final category = _categoryController.text.trim();
    if (name.isEmpty || price == null || category.isEmpty) return;

    setState(() => _saving = true);
    final service = ref.read(menuServiceProvider);
    final item = MenuItemModel(
      id: widget.existing?.id ?? '',
      name: name,
      price: price,
      category: category,
      description: _descController.text.trim(),
      isAvailable: _isAvailable,
      imageUrl: widget.existing?.imageUrl ?? '',
    );

    if (widget.existing == null) {
      await service.addItem(widget.cafeId, item);
    } else {
      await service.updateItem(widget.cafeId, item);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Add item' : 'Edit item'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            style: TextStyle(color: AppColors.crema),
            decoration: InputDecoration(hintText: 'Item name'),
          ),
          SizedBox(height: 14),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: AppColors.crema),
            decoration: InputDecoration(hintText: 'Price (₹)'),
          ),
          SizedBox(height: 14),
          TextField(
            controller: _categoryController,
            style: TextStyle(color: AppColors.crema),
            decoration: InputDecoration(hintText: 'Category (e.g. Bevarges)'),
          ),
          SizedBox(height: 14),
          TextField(
            controller: _descController,
            maxLines: 2,
            style: TextStyle(color: AppColors.crema),
            decoration: InputDecoration(hintText: 'Description (optional)'),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'In stock',
                  style: TextStyle(color: AppColors.crema),
                ),
              ),
              Switch(
                value: _isAvailable,
                activeColor: AppColors.gold,
                onChanged: ((value) => setState(() => _isAvailable = value)),
              ),
            ],
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.ink,
                    ),
                  )
                : Text('Save'),
          ),
        ],
      ),
    );
  }
}
