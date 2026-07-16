import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/providers/staff_management_providers.dart';
import 'package:staff_app/theme/app_colors.dart';

class AddStaffScreen extends ConsumerStatefulWidget {
  final String cafeId;
  const AddStaffScreen({super.key, required this.cafeId});

  @override
  ConsumerState<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends ConsumerState<AddStaffScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = 'waiter';
  bool _saving = false;
  String? _error;

  Future<void> _create() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final passwprd = _passwordController.text;
    if (name.isEmpty || email.isEmpty || passwprd.length < 6) {
      setState(() => _error = "Fill all fields. Password needs 6+ characters.");
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final callable = ref
          .read(functionsProvider)
          .httpsCallable('createStaffAccount');
      await callable.call({
        'cafeId': widget.cafeId,
        'email': email,
        'password': passwprd,
        'name': name,
        'phone': _phoneController.text.trim(),
        'role': _role,
      });
      if (mounted) Navigator.pop(context);
    } on FirebaseFunctionsException catch (e) {
      setState(() => _error = e.message ?? 'Could not create account.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add stff')),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            style: TextStyle(color: AppColors.crema),
            decoration: InputDecoration(hintText: 'Name'),
          ),
          SizedBox(height: 14),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: AppColors.crema),
            decoration: InputDecoration(hintText: 'Email'),
          ),
          SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: TextStyle(color: AppColors.crema),
            decoration: InputDecoration(hintText: 'Temporary password'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: AppColors.crema),
            decoration: InputDecoration(hintText: 'Phone (optional)'),
          ),
          SizedBox(height: 14),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                items: [
                  DropdownMenuItem(value: 'waiter', child: Text('Waiter')),
                  DropdownMenuItem(value: 'chef', child: Text('Chef')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'waiter'),
              ),
            ),
          ),
          if (_error != null) ...[
            SizedBox(height: 14),
            Text(
              _error!,
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ],
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _create,
            child: _saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.ink,
                    ),
                  )
                : Text('Create account'),
          ),
        ],
      ),
    );
  }
}
