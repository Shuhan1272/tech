import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/snackbar_helper.dart';
import '../widgets/primary_button.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  // Scroll and Focus controllers to handle keyboard visibility and visibility toggle
  final ScrollController _scrollController = ScrollController();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey _requirementsKey = GlobalKey();

  bool _obscurePassword = true;
  bool _obscurePassword2 = true;
  bool _showPasswordRequirements = false; // Controls visibility of the checklist

  // Password validation tracking state
  bool _hasLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialSymbol = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _passwordFocusNode.addListener(_onPasswordFocusChange);
  }

  void _onPasswordChanged() {
    final val = _passwordController.text;
    setState(() {
      _hasLength = val.length >= 8;
      _hasUppercase = val.contains(RegExp(r'[A-Z]'));
      _hasLowercase = val.contains(RegExp(r'[a-z]'));
      _hasDigit = val.contains(RegExp(r'[0-9]'));
      _hasSpecialSymbol = val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+\[\]\\/`~]'));

      // Keep requirements visible if focused or if there's text typed, hide only if empty and unfocused
      _showPasswordRequirements = _passwordFocusNode.hasFocus || val.isNotEmpty;
    });
  }

  void _onPasswordFocusChange() {
    setState(() {
      // Show requirements box when focused, or keep visible if text isn't empty
      _showPasswordRequirements = _passwordFocusNode.hasFocus || _passwordController.text.isNotEmpty;
    });

    if (_passwordFocusNode.hasFocus) {
      // Automatically scroll down to reveal the requirements box above the keyboard
      Future.delayed(const Duration(milliseconds: 300), () {
        final context = _requirementsKey.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.8,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _passwordFocusNode.removeListener(_onPasswordFocusChange);
    _passwordFocusNode.dispose();
    _scrollController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
<<<<<<< HEAD

    if (!_hasLength || !_hasUppercase || !_hasLowercase || !_hasDigit || !_hasSpecialSymbol) {
      AppSnackbar.showError(context, 'Please meet all password requirements');
      return;
    }

=======
>>>>>>> 89a0b742e33e68f3ed2c4dcf319164e5067a197f
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
<<<<<<< HEAD
=======
      // Note: no longer .trim()-ing passwords. The old code trimmed them
      // on register but the backend stores exactly what it receives, so a
      // password with a leading/trailing space would be saved trimmed here
      // and then fail to match on a login screen that trimmed differently.
>>>>>>> 89a0b742e33e68f3ed2c4dcf319164e5067a197f
      password: _passwordController.text,
      password2: _password2Controller.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(
<<<<<<< HEAD
=======
            // Carrying the whole form forward (not just the email) so
            // "Resend OTP" on the next screen can actually re-submit
            // registration — the backend regenerates a fresh OTP for an
            // unverified email on a repeat /register/ call. Previously
            // VerifyEmailScreen only received the email, so its "Resend"
            // link just showed a fake success SnackBar without calling
            // anything at all.
>>>>>>> 89a0b742e33e68f3ed2c4dcf319164e5067a197f
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            password: _passwordController.text,
            password2: _password2Controller.text,
          ),
        ),
      );
    } else if (auth.errorMessage != null) {
      AppSnackbar.showError(context, auth.errorMessage!);
    }
  }

<<<<<<< HEAD
  Widget _buildRequirementRow(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            met ? Icons.check : Icons.circle,
            size: 14,
            color: met ? Colors.blue : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: met ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

=======
>>>>>>> 89a0b742e33e68f3ed2c4dcf319164e5067a197f
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
<<<<<<< HEAD
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_add_alt_1_outlined, size: 36, color: primary),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Join TechNest',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Create your account to start shopping',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter your phone number';
                    if (value.trim().length < 11) return 'Please enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
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
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a password';
                    if (value.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                ),

                // Conditionally display requirement indicators only when focused or text is active
                if (_showPasswordRequirements) ...[
                  const SizedBox(height: 10),
                  Container(
                    key: _requirementsKey,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password must contain:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        _buildRequirementRow('At least 1 number (0...9)', _hasDigit),
                        _buildRequirementRow('At least 8 characters length', _hasLength),
                        _buildRequirementRow('At least 1 lowercase letter (a...z)', _hasLowercase),
                        _buildRequirementRow('At least 1 uppercase letter (A...Z)', _hasUppercase),
                        _buildRequirementRow('At least 1 special symbol (!...\$)', _hasSpecialSymbol),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                TextFormField(
                  controller: _password2Controller,
                  obscureText: _obscurePassword2,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword2 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword2 = !_obscurePassword2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                PrimaryButton(label: 'Register', isLoading: auth.isLoading, onPressed: _submit),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Login')),
                  ],
                ),
              ],
            ),
          ),
=======
      // CENTERING FIX: the form was a plain top-aligned ListView, so on a
      // tall screen it hugged the AppBar with dead space below. Same
      // recipe as login_screen: a min-height box lets the column center
      // itself when there is room, and the scroll view keeps it usable
      // when the content (or the keyboard) is taller than the viewport.
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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_add_alt_1_outlined, size: 36, color: primary),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Join TechNest',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create your account to start shopping',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(labelText: 'First Name'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(labelText: 'Last Name'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your phone number';
                          if (value.trim().length < 11) return 'Please enter a valid phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
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
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          helperText: 'At least 8 characters',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a password';
                          if (value.length < 8) return 'Password must be at least 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password2Controller,
                        obscureText: _obscurePassword2,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword2 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscurePassword2 = !_obscurePassword2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please confirm your password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      PrimaryButton(label: 'Register', isLoading: auth.isLoading, onPressed: _submit),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account?', style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Login')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
>>>>>>> 89a0b742e33e68f3ed2c4dcf319164e5067a197f
        ),
      ),
    );
  }
}