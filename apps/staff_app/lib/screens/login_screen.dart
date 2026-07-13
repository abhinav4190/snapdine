import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/providers/auth_provider.dart';
import 'package:staff_app/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginHandle() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await ref
          .read(authServiceProvider)
          .signIn(_emailController.text.trim(), _passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = switch (e.code) {
          'user-not-found' ||
          'invalid-credential' => 'No account found with these details.',
          'wrong-password' => 'Incorrect password.',
          'invalid-email' => 'Enter a valid email address.',
          _ => 'Login failed. Please try again.',
        };
      });
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
       onTap: ()=>  FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    PhosphorIconsBold.storefront,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Team Login',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sign in with the account provided by your cafe administrator.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(PhosphorIconsRegular.envelope),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(PhosphorIconsRegular.lock),
                    suffixIcon: IconButton(
                      onPressed: () { setState(
                        () => _obscurePassword = !_obscurePassword,
                      );
                      },
                      icon: Icon(_obscurePassword ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash),
                    ),
                  ),
                ),
                if(_errorText!=null) ...[
                  const SizedBox(height: 12,),
                  Text(_errorText!, style: TextStyle(
                    color: AppColors.error, fontSize: 13
                  ),)
                ],
                const SizedBox(height: 24,),
                ElevatedButton(onPressed: _isLoading ? null : _loginHandle, child: _isLoading ? SizedBox(
                  width: 20,
                  height: 20,
                  child:  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ) : Text('Log In'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
