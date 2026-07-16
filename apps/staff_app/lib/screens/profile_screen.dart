import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/staff_model.dart';
import 'package:staff_app/providers/auth_provider.dart';
import 'package:staff_app/providers/billing_providers.dart';
import 'package:staff_app/providers/staff_management_providers.dart';
import 'package:staff_app/screens/add_staff_screen.dart';
import 'package:staff_app/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final StaffModel staff;
  const ProfileScreen({super.key, required this.staff});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _gstController = TextEditingController();
  final _serviceContoller = TextEditingController();

  bool _loaded = false;
  bool _saving = false;
  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(cafeConfigProvider(widget.staff.cafeId));
    final staffListAsync = ref.watch(
      staffListStreamProvider(widget.staff.cafeId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authServiceProvider).signOut(),
            icon: Icon(PhosphorIconsRegular.signOut, size: 20),
          ),
        ],
      ),
      body: configAsync.when(
        data: (data) {
          if (!_loaded) {
            _nameController.text = data.name;
            _gstController.text = data.gstPercent.toStringAsFixed(0);
            _serviceContoller.text = data.serviceChargePercent.toStringAsFixed(
              0,
            );
            _loaded = true;
          }

          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              Text(
                'Cafe details',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: TextStyle(color: AppColors.crema),
                decoration: InputDecoration(hintText: 'Cafe name'),
              ),
              SizedBox(height: 12),
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
              SizedBox(height: 14),
              ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await ref
                            .read(cafeServiceProvider)
                            .updateCafeConfig(
                              widget.staff.cafeId,
                              name: _nameController.text.trim(),
                              gstPercent:
                                  double.tryParse(_gstController.text.trim()) ??
                                  0,
                              serviceChargePercent:
                                  double.tryParse(
                                    _serviceContoller.text.trim(),
                                  ) ??
                                  0,
                            );
                      },
                child: _saving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ink,
                        ),
                      )
                    : Text('Save changes'),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Staff',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddStaffScreen(cafeId: widget.staff.cafeId),
                      ),
                    ),
                    icon: Icon(
                      PhosphorIconsBold.plus,
                      size: 20,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              staffListAsync.when(
                data: (staffList) {
                  final others = staffList
                      .where((s) => s['uid'] != widget.staff.uid)
                      .toList();
                  if (others.isEmpty) {
                    return Text(
                      'No staff added yet',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    );
                  }
                  return Column(
                    children: others.map((s) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['name'] as String? ?? '',
                                    style: TextStyle(
                                      color: AppColors.crema,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    (s['role'] as String? ?? '').toUpperCase(),
                                    style: TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColors.surface,
                                    title: Text(
                                      'Remove staff?',
                                      style: TextStyle(color: AppColors.crema),
                                    ),
                                    content: Text(
                                      '${s['name']} will lose access immediately.',
                                      style: TextStyle(color: AppColors.muted),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          'Remove',
                                          style: TextStyle(
                                            color: AppColors.rosewood,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if(confirmed==true){
                                  final callable = ref.read(functionsProvider).httpsCallable('deleteStaffAccount');
                                  await callable.call({
                                    'cafeId': widget.staff.cafeId,
                                    'staffUid': s['uid']
                                  });
                                }
                              },
                              icon: Icon(
                                PhosphorIconsThin.trash,
                                size: 20,
                                color: AppColors.rosewood,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                error: (_, __) => Text(
                  'Cpuld not load staff',
                  style: TextStyle(color: AppColors.muted),
                ),
                loading: () => Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ),
            ],
          );
        },
        error: (_, __) => Center(child: Text('Could not load profile')),
        loading: () =>
            Center(child: CircularProgressIndicator(color: AppColors.gold)),
      ),
    );
  }
}
