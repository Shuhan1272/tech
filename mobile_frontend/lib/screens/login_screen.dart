import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../core/snackbar_helper.dart';
import '../widgets/primary_button.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      // Fixed: this used to push a local, dead-end "Login Successful!"
      // placeholder screen defined at the bottom of this same file,
      // instead of the real HomeScreen. Now it goes to the actual named
      // route and clears the auth stack, so the back button can't return
      // to the login form after signing in.
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else if (auth.errorMessage != null) {
      AppSnackbar.showError(context, auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // CENTERING FIX:
      // The form used to be a ListView whose first child was a fixed
      // SizedBox(height: 40), so everything sat pinned near the top and
      // left a big empty gap at the bottom on taller phones.
      //
      // LayoutBuilder reports the available height; the ConstrainedBox
      // gives the column at least that much room so
      // MainAxisAlignment.center can genuinely center it, while
      // SingleChildScrollView still lets the whole thing scroll when the
      // keyboard opens or the screen is too short (in that case the column
      // is simply taller than the viewport and behaves exactly like
      // before). The padding is on the scroll view, so the min-height
      // calculation subtracts the same 24px top + 24px bottom.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight =
            constraints.maxHeight > 48 ? constraints.maxHeight - 48 : 0.0;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.shopping_bag_rounded, size: 44, color: primary),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue shopping on TechNest',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your email';
                          if (!value.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        // Removed the old "at least 6 characters" rule here. On a
                        // LOGIN form that validation is wrong: it rejects the
                        // user's real password locally before the request is even
                        // sent if their password predates any rule change, and it
                        // leaks your password policy. Length rules belong on
                        // register/reset, which is where they now live.
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter your password' : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      PrimaryButton(label: 'Log in', isLoading: auth.isLoading, onPressed: _submit),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?", style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            ),
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
