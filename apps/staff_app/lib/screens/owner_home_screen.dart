import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/staff_model.dart';
import 'package:staff_app/providers/auth_provider.dart';
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
                            'Add tables, generate QR codes',
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
          ],
        ),
      ),
    );
  }
}
