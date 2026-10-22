import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/snackbar_helper.dart';
import '../widgets/primary_button.dart';

/// "Edit Profile" on the profile menu had an empty onTap, and although
/// AuthService had an updateProfile() method, nothing in the app ever
/// called it — the PATCH /me/ endpoint was completely unreachable from
/// the UI.
///
/// PHONE FIXES (this screen used to demand the phone number again):
///  1. The current number was not shown. Two reasons: the field was only
///     fed from whatever was already cached in AuthProvider, and after a
///     fresh registration + email verification that cached object came
///     from the verify-email response — which contains no `phone` key at
///     all. The screen now pulls the real profile from GET /accounts/me/
///     (which does return phone) as soon as it opens, so the stored
///     number is always on screen.
///  2. The field had a hard `'Required'` validator, so saving a name
///     change was impossible without typing the number again — and the
///     backend's User.phone is non-blank, so PATCHing a cleared value
///     would have been rejected anyway. The phone is now optional: leave
///     it untouched (or empty) and the stored number is kept; type a
///     different one and only then is it sent to the API.
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

  /// The phone number currently stored on the account. Compared against
  /// what's in the field on save to decide whether to send it at all.
  String _savedPhone = '';

  /// What each field was pre-filled with, so the background profile
  /// refresh can tell "still untouched" from "user is typing".
  String _prefillFirst = '';
  String _prefillLast = '';
  String _prefillPhone = '';

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().user;
    _prefillFirst = (user?['first_name'] ?? '').toString();
    _prefillLast = (user?['last_name'] ?? '').toString();
    _prefillPhone = (user?['phone'] ?? '').toString();
    _savedPhone = _prefillPhone;

    _firstName = TextEditingController(text: _prefillFirst);
    _lastName = TextEditingController(text: _prefillLast);
    _phone = TextEditingController(text: _prefillPhone);

    // Fetch the authoritative profile once the first frame is up, so the
    // mobile number is filled in even when the cached user object doesn't
    // carry one (see class comment).
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);

    final auth = context.read<AuthProvider>();
    await auth.refreshProfile();
    if (!mounted) return;

    final user = auth.user;
    final latestPhone = (user?['phone'] ?? '').toString().trim();

    setState(() {
      _isRefreshing = false;
      if (user != null) {
        // Only overwrite a field if the user hasn't typed into it yet.
        final first = (user['first_name'] ?? '').toString();
        final last = (user['last_name'] ?? '').toString();
        if (_firstName.text == _prefillFirst) _firstName.text = first;
        if (_lastName.text == _prefillLast) _lastName.text = last;
        if (_phone.text.trim() == _prefillPhone.trim()) _phone.text = latestPhone;
      }
      if (latestPhone.isNotEmpty) _savedPhone = latestPhone;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final typedPhone = _phone.text.trim();

    // The number is only included in the PATCH when it has actually been
    // changed. Untouched / blank => null => "keep the stored number".
    final phoneToSend =
    (typedPhone.isNotEmpty && typedPhone != _savedPhone) ? typedPhone : null;

    final success = await auth.updateProfile(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: phoneToSend,
    );
    if (!mounted) return;
    if (success) {
      AppSnackbar.showSuccess(
        context,
        phoneToSend == null
            ? 'Profile updated — your phone number was kept'
            : 'Profile updated',
      );
      Navigator.pop(context);
    } else {
      AppSnackbar.showError(context, auth.errorMessage ?? 'Could not update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.user?['email']?.toString() ?? '';

    // Nothing cached to show at all (rare) — wait for the fetch instead of
    // flashing an empty form.
    if (auth.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: Column(
          children: [
            if (_isRefreshing) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          // The stored number is shown right here, so it is
                          // obvious that nothing has to be retyped.
                          helperText: _savedPhone.isEmpty
                              ? 'Optional — you can add your number here'
                              : 'Current: $_savedPhone  (leave unchanged to keep it)',
                          helperMaxLines: 2,
                        ),
                        validator: (value) {
                          // Optional on this screen: the account already has
                          // a number, so an empty (or untouched) field must
                          // never block saving a name change.
                          final v = (value ?? '').trim();
                          if (v.isEmpty || v == _savedPhone.trim()) return null;
                          final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.length < 10 || digits.length > 15) {
                            return 'Please enter a valid phone number';
                          }
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
          ],
        ),
      ),
    );
  }
}