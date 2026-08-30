import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider()..checkAuthStatus(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TechNest',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return Scaffold(
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (authProvider.isAuthenticated) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('TechNest'),
                  backgroundColor: Colors.deepPurple,
                ),
                body: const Center(
                  child: Text(
                    'Welcome to TechNest!',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              );
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}