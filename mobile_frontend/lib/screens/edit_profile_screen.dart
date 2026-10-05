import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/snackbar_helper.dart';
import '../widgets/primary_button.dart';

/// NEW SCREEN. "Edit Profile" on the profile menu had an empty onTap, and
/// although AuthService had an updateProfile() method, nothing in the app
/// ever called it — the PATCH /me/ endpoint was completely unreachable
/// from the UI.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstName = TextEditingController(text: user?['first_name']?.toString() ?? '');
    _lastName = TextEditingController(text: user?['last_name']?.toString() ?? '');
    _phone = TextEditingController(text: user?['phone']?.toString() ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: _phone.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      AppSnackbar.showSuccess(context, 'Profile updated');
      Navigator.pop(context);
    } else {
      AppSnackbar.showError(context, auth.errorMessage ?? 'Could not update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.user?['email']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Email is read_only on your UserSerializer, so it's shown
                // as a disabled field rather than an editable one that
                // would silently fail to save.
                TextFormField(
                  initialValue: email,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    helperText: 'Email cannot be changed',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _firstName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _lastName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.trim().length < 11) return 'Please enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Save Changes', isLoading: auth.isLoading, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
