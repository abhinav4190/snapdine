import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/staff_model.dart';
import 'package:staff_app/providers/billing_providers.dart';
import 'package:staff_app/providers/table_providers.dart';
import 'package:staff_app/screens/owner_home_screen.dart';
import 'package:staff_app/services/menu_ocr_screen.dart';
import 'package:staff_app/theme/app_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final StaffModel staff;
  final bool startAtMenuStep;
  const OnboardingScreen({
    super.key,
    required this.staff,
    required this.startAtMenuStep,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late int _step = widget.startAtMenuStep ? 1 : 0;
  final _nameController = TextEditingController();
  final _tablesController = TextEditingController();
  final _gstController = TextEditingController();
  final _serviceContoller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tablesController.dispose();
    _gstController.dispose();
    _serviceContoller.dispose();
    super.dispose();
  }

  Future<void> _saveBasicInfo() async {
    final name = _nameController.text.trim();
    final tableCount = int.tryParse(_tablesController.text.trim()) ?? 0;
    final gst = double.tryParse(_gstController.text.trim()) ?? 0;
    final service = double.tryParse(_serviceContoller.text.trim()) ?? 0;
    if (name.isEmpty || tableCount <= 0) return;

    setState(() => _saving = true);

    await ref
        .read(cafeServiceProvider)
        .saveOnboardingBasicInfo(
          widget.staff.cafeId,
          name: name,
          gstPercent: gst,
          serviceChargePercent: service,
        );
    final tableService = ref.read(tableServiceProvider);
    for (int i = 1; i <= tableCount; i++) {
      await tableService.addTable(widget.staff.cafeId, i);
    }
    if (mounted) {
      setState(() {
        _saving = false;
        _step = 1;
      });
    }
  }

  Future<void> _finish() async {
    await ref.read(cafeServiceProvider).completeOnboarding(widget.staff.cafeId);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OwnerHomeScreen(staff: widget.staff)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
         onTap: ()=>  FocusScope.of(context).unfocus(),

      child: Scaffold(
        body: SafeArea(child: _step == 0 ? _buildBasicInfoStep() : _buildMenuStep()),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return GestureDetector(
         onTap: ()=>  FocusScope.of(context).unfocus(),

      child: Padding(
        padding: EdgeInsetsGeometry.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsThin.storefront, size: 36, color: AppColors.gold),
            SizedBox(height: 20),
            Text(
              'Set up your cafe',
              style: TextStyle(
                color: AppColors.crema,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'This only takes a minute.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            SizedBox(height: 28),
            TextField(
              controller: _nameController,
              style: TextStyle(color: AppColors.crema),
              decoration: InputDecoration(hintText: 'Cafe name'),
            ),
            SizedBox(height: 14),
            TextField(
              controller: _tablesController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.crema),
              decoration: InputDecoration(hintText: 'Number of tables'),
            ),
            SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _gstController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.crema),
                    decoration: InputDecoration(hintText: 'GST %'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _serviceContoller,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.crema),
                    decoration: InputDecoration(hintText: 'Service charge %'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _saveBasicInfo,
              child: _saving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink,
                      ),
                    )
                  : Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuStep() {
    return GestureDetector(
         onTap: ()=>  FocusScope.of(context).unfocus(),

      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsThin.sparkle, size: 36, color: AppColors.gold),
            SizedBox(height: 20),
            Text(
              'Add your menu',
              style: TextStyle(
                color: AppColors.crema,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Scan a photo of your physical menu and AI will fill it in for you. You can always add items manually later.",
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MenuOcrScreen(cafeId: widget.staff.cafeId),
                  ),
                );
                await _finish();
              },
              label: Text('Scan menu now'),
              icon: Icon(PhosphorIconsBold.camera, size: 18),
            ),
            SizedBox(height: 14),
            TextButton(
              onPressed: _finish,
              child: Text(
                "Skip, I will add menu later.",
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
