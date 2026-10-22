// Widget tests for the screens touched in this pass.
//
// The previous version of this file was still the untouched Flutter
// counter template: it pumped a `MyApp` class that doesn't exist anywhere
// in this project (the root widget is `TechNestApp`), so `flutter analyze`
// reported a hard error that would hide any real problem in the codebase.
//
// These tests build the real screens with the provider they depend on.
// Note they deliberately avoid AuthProvider.checkAuthStatus()/logout()/
// refreshProfile() against the network: TokenStorage uses
// flutter_secure_storage, whose platform channel isn't available in a
// plain widget test. Reading the provider (all these screens do at build
// time) needs no plugins, and `_FakeAuthProvider` below stubs out the one
// call EditProfileScreen makes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile_frontend/core/app_theme.dart';
import 'package:mobile_frontend/providers/auth_provider.dart';
import 'package:mobile_frontend/screens/edit_profile_screen.dart';
import 'package:mobile_frontend/screens/login_screen.dart';
import 'package:mobile_frontend/screens/register_screen.dart';
import 'package:mobile_frontend/screens/verify_email_screen.dart';

/// AuthProvider with a fixed user and no network access.
class _FakeAuthProvider extends AuthProvider {
  _FakeAuthProvider(this._fakeUser);

  final Map<String, dynamic> _fakeUser;

  String? lastFirstName;
  String? lastLastName;
  String? lastPhone;
  bool lastResult = false;

  @override
  Map<String, dynamic>? get user => _fakeUser;

  @override
  Future<void> refreshProfile() async {
    // No-op: the widget tests must not hit the API/secure storage.
  }

  @override
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    lastFirstName = firstName;
    lastLastName = lastName;
    lastPhone = phone;
    return lastResult;
  }
}

Widget _wrap(Widget child, {AuthProvider? auth}) {
  return ChangeNotifierProvider<AuthProvider>(
    create: (_) => auth ?? AuthProvider(),
    child: MaterialApp(theme: AppTheme.light, home: child),
  );
}

void main() {
  testWidgets('login screen renders the sign-in form', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('login screen validates empty fields locally', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('register screen renders the registration form', (tester) async {
    await tester.pumpWidget(_wrap(const RegisterScreen()));

    expect(find.text('Join TechNest'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('verify screen shows an x placeholder, never 000000 or a pre-filled code',
          (tester) async {
        await tester.pumpWidget(_wrap(const VerifyEmailScreen(email: 'a@b.com')));

        // The hint is drawn by the decoration, so look for the placeholder text
        // rather than the (empty) field content.
        expect(find.text('xxxxxx'), findsOneWidget);
        expect(find.text('000000'), findsNothing);
      });

  testWidgets('edit profile shows the stored phone number', (tester) async {
    final auth = _FakeAuthProvider({
      'email': 'tanvir@example.com',
      'first_name': 'Tanvir',
      'last_name': 'Ahmed',
      'phone': '01712345678',
    });

    await tester.pumpWidget(_wrap(const EditProfileScreen(), auth: auth));
    await tester.pump();

    expect(find.textContaining('01712345678'), findsWidgets);
  });

  testWidgets('editing only the name does not require the phone number',
          (tester) async {
        final auth = _FakeAuthProvider({
          'email': 'tanvir@example.com',
          'first_name': 'Tanvir',
          'last_name': 'Ahmed',
          'phone': '01712345678',
        });

        await tester.pumpWidget(_wrap(const EditProfileScreen(), auth: auth));
        await tester.pump();

        await tester.enterText(find.byType(TextFormField).at(1), 'Tanvir Jr');
        await tester.tap(find.text('Save Changes'));
        await tester.pump();

        // The form validated and called the API without the phone being
        // re-entered: phone must be null ("leave the stored number alone").
        expect(auth.lastFirstName, 'Tanvir Jr');
        expect(auth.lastLastName, 'Ahmed');
        expect(auth.lastPhone, isNull);
        expect(find.text('Please enter a valid phone number'), findsNothing);
      });
}