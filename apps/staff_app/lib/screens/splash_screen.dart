import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:staff_app/screens/auth_gate.dart';
import 'package:staff_app/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset('assets/lottie/loading.json'),
        ),
      ),
    );
  }
}
