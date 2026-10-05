import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/snackbar_helper.dart';
import '../widgets/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  // Optional — only needed to make "Resend" actually work (see _resend).
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? password;
  final String? password2;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.password,
    this.password2,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isResending = false;

  bool get _canResend =>
      widget.phone != null && widget.firstName != null && widget.password != null;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyEmail(email: widget.email, otp: _otpController.text.trim());
    if (!mounted) return;
    if (success) {
      // Fixed: previously pushed a local dead-end "Email Verified!"
      // placeholder defined at the bottom of this same file, instead of
      // the real HomeScreen.
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else if (auth.errorMessage != null) {
      AppSnackbar.showError(context, auth.errorMessage!);
    }
  }

  Future<void> _resend() async {
    // Fixed: this used to just show a SnackBar claiming "OTP resent"
    // without calling anything. Since the backend regenerates a fresh OTP
    // for an unverified email on a repeat /register/ call, a real resend
    // is just replaying registration with the same details.
    if (!_canResend) return;
    setState(() => _isResending = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: widget.email,
      phone: widget.phone!,
      firstName: widget.firstName!,
      lastName: widget.lastName ?? '',
      password: widget.password!,
      password2: widget.password2 ?? widget.password!,
    );
    if (!mounted) return;
    setState(() => _isResending = false);
    if (success) {
      AppSnackbar.showSuccess(context, 'A new code has been sent to ${widget.email}');
    } else if (auth.errorMessage != null) {
      AppSnackbar.showError(context, auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: primary.withOpacity(0.08), shape: BoxShape.circle),
                    child: Icon(Icons.mark_email_read_outlined, size: 44, color: primary),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Verify Your Email', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit code to ${widget.email}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(counterText: '', hintText: '000000'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter the code';
                    if (value.length != 6) return 'Code must be 6 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Verify', isLoading: auth.isLoading, onPressed: _submit),
                const SizedBox(height: 12),
                Center(
                  child: _canResend
                      ? TextButton(
                    onPressed: _isResending ? null : _resend,
                    child: _isResending
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Didn't receive it? Resend"),
                  )
                      : Text(
                    "Check your spam folder if you don't see it",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
