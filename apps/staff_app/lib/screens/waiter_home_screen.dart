import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/staff_model.dart';
import 'package:staff_app/providers/auth_provider.dart';
import 'package:staff_app/theme/app_colors.dart';

class WaiterHomeScreen extends ConsumerWidget {
  final StaffModel staff;
  const WaiterHomeScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(staff.name),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.signOut, size: 20),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: Placeholder()
    );
  }
}
