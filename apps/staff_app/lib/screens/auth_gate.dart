import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/staff_model.dart';
import 'package:staff_app/providers/auth_provider.dart';
import 'package:staff_app/screens/chef_home_screen.dart';
import 'package:staff_app/screens/login_screen.dart';
import 'package:staff_app/screens/owner_home_screen.dart';
import 'package:staff_app/screens/waiter_home_screen.dart';
import 'package:staff_app/theme/app_colors.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(loading: () => _LoadingScreen(), error: (error, stackTrace) => _ErrorScreen(message: error.toString()), data: (data) {
      if(data == null) return LoginScreen();
      return const _ProfileGate();
    },);
  }
}

class _ProfileGate extends ConsumerWidget {
  const _ProfileGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(staffProfileProvider);

    return profileState.when(
      data: (staff) {
        if (staff == null) return const _NotOnbardedScreen();
        return switch (staff.role) {
          StaffRole.owner => OwnerHomeScreen(staff: staff,),
          StaffRole.waiter => WaiterHomeScreen(staff: staff,),
          StaffRole.chef => ChefHomeScreen(staff: staff,),

          // StaffRole.waiter => OwnerHomeScreen(),
          // StaffRole.chef => OwnerHomeScreen(),
        };
      },
      error: (error, _) => _ErrorScreen(message: error.toString()),
      loading: () => _LoadingScreen(),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2,),
            SizedBox(height: 12),
              Text('Just a moment', textAlign: TextAlign.center, ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                PhosphorIconsRegular.warningCircle,
                size: 40,
                color: AppColors.error,
              ),
              SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotOnbardedScreen extends ConsumerWidget {
  const _NotOnbardedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconsRegular.userCircleMinus,
                size: 40,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                "Your account isn't linked to a cafe yet. Ask administrator to add you.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                child: Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
