import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/staff_model.dart';
import 'package:staff_app/providers/auth_provider.dart';
import 'package:staff_app/theme/app_colors.dart';

class OwnerHomeScreen extends ConsumerWidget {
  final StaffModel staff;
  const OwnerHomeScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${staff.name}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(onPressed: () => ref.read(authServiceProvider).signOut(), icon: Icon(PhosphorIconsRegular.signOut)),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12,),
            Text('Owner Dashboard'),
            SizedBox(height: 4,),
            Text('Cafe: ${staff.cafeId}')
          ],
        ),
      ),
    );
  }
}