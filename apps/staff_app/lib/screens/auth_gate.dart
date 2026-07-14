import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
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

    return authState.when(
      loading: () => const _LoadingScreen(),
      error: (err, _) => _ErrorScreen(message: err.toString()),
      data: (user) {
        if (user == null) return const LoginScreen();
        return const _StaffProfileGate();
      },
    );
  }
}

class _StaffProfileGate extends ConsumerWidget {
  const _StaffProfileGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(staffProfileProvider);

    return profileState.when(
      loading: () => const _LoadingScreen(),
      error: (err, _) => _ErrorScreen(message: err.toString()),
      data: (staff) {
        if (staff == null) return const _NotOnboardedScreen();
        return switch (staff.role) {
          StaffRole.owner => OwnerHomeScreen(staff: staff),
          StaffRole.waiter => WaiterHomeScreen(staff: staff),
          StaffRole.chef => ChefHomeScreen(staff: staff),
        };
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie.asset(
            //   'assets/lottie/loading.json',
            //   width: 120,
            //   height: 120,
            //   repeat: true,
            // ),
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: 12),
            Text('Just a moment', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                PhosphorIconsThin.warningCircle,
                size: 36,
                color: AppColors.error,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotOnboardedScreen extends ConsumerWidget {
  const _NotOnboardedScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                PhosphorIconsThin.userCircleMinus,
                size: 36,
                color: AppColors.muted,
              ),
              const SizedBox(height: 14),
              Text(
                'Your account isn\'t linked to a cafe yet.\nAsk administrator to add you.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                child: const Text(
                  'Log out',
                  style: TextStyle(color: AppColors.gold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
