import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/snackbar_helper.dart';
import '../widgets/primary_button.dart';

/// NEW SCREEN. "Change Password" on the profile menu had an empty onTap.
/// AuthService.changePassword() existed but nothing ever called it, so
/// POST /change-password/ was unreachable from the UI.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPass = TextEditingController();
  final _newPass2 = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureNew2 = true;

  @override
  void dispose() {
    _current.dispose();
    _newPass.dispose();
    _newPass2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(
      currentPassword: _current.text,
      newPassword: _newPass.text,
      newPassword2: _newPass2.text,
    );
    if (!mounted) return;
    if (success) {
      AppSnackbar.showSuccess(context, 'Password changed successfully');
      Navigator.pop(context);
    } else {
      AppSnackbar.showError(context, auth.errorMessage ?? 'Could not change password');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _current,
                  obscureText: _obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter your current password' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _newPass,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_reset),
                    helperText: 'At least 8 characters',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter a new password';
                    if (v.length < 8) return 'Password must be at least 8 characters';
                    if (v == _current.text) return 'New password must be different';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _newPass2,
                  obscureText: _obscureNew2,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew2 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureNew2 = !_obscureNew2),
                    ),
                  ),
                  validator: (v) => (v != _newPass.text) ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Change Password', isLoading: auth.isLoading, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
