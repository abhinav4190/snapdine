import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/firebase_options.dart';
import 'package:staff_app/screens/auth_gate.dart';
import 'package:staff_app/screens/splash_screen.dart';
import 'package:staff_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: const SnapDineStaffApp()));
}

class SnapDineStaffApp extends StatelessWidget {
  const SnapDineStaffApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snap Dine',
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
