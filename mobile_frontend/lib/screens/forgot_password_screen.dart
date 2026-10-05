import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/snackbar_helper.dart';
import '../widgets/primary_button.dart';
import 'reset_password_screen.dart';

/// Rewritten to go through AuthProvider instead of calling AuthService
/// directly. Previously this screen bypassed the provider entirely, so it
/// had its own local _isLoading and its own error handling — a different
/// pattern from every other auth screen in the app.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isSubmittingOtp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPassword(email: _emailController.text.trim());
    if (!mounted) return;
    if (success) {
      setState(() => _otpSent = true);
      AppSnackbar.showSuccess(context, 'If an account exists, a reset code has been sent.');
    } else if (auth.errorMessage != null) {
      AppSnackbar.showError(context, auth.errorMessage!);
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    if (_otpController.text.trim().length != 6) {
      AppSnackbar.showError(context, 'Please enter the 6-digit code');
      return;
    }
    setState(() => _isSubmittingOtp = true);
    final auth = context.read<AuthProvider>();
    final resetToken = await auth.verifyPasswordOtp(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmittingOtp = false);
    if (resetToken != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(resetToken: resetToken)),
      );
    } else if (auth.errorMessage != null) {
      AppSnackbar.showError(context, auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: primary.withOpacity(0.08), shape: BoxShape.circle),
                    child: Icon(Icons.lock_reset, size: 44, color: primary),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Reset Password', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'Enter the 6-digit code we sent to your email'
                      : 'Enter your email to receive a password reset code',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_otpSent,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter your email';
                    if (!value.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (!_otpSent)
                  PrimaryButton(label: 'Send Code', isLoading: auth.isLoading, onPressed: _sendOtp),

                if (_otpSent) ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(counterText: '', hintText: '000000'),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(label: 'Verify Code', isLoading: _isSubmittingOtp, onPressed: _verifyOtp),
                  Center(
                    child: TextButton(
                      onPressed: auth.isLoading ? null : _sendOtp,
                      child: const Text('Resend Code'),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                Center(
                  child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
