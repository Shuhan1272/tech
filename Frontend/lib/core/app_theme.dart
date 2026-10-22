import 'package:flutter/material.dart';

/// One place for every color, shape, and text style in the app.
///
/// Before this, every screen redefined its own ElevatedButton style, its
/// own OutlineInputBorder, its own AppBar colors — some screens used a
/// solid deepPurple AppBar (auth screens), others a flat white one
/// (shopping screens), which read as two different apps stitched
/// together. Centralizing it here means every screen just uses the plain
/// widget (ElevatedButton, TextFormField, AppBar with no args) and gets
/// the same look automatically — and changing the brand color later means
/// editing this one file instead of twenty.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF6750E4);
  static const Color primaryDark = Color(0xFF4F3FC0);
  static const Color background = Color(0xFFF7F7FB);
  static const Color surface = Colors.white;
  static const Color danger = Color(0xFFE53935);
  static const Color success = Color(0xFF2E7D32);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,

      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textPrimary),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 15, color: textPrimary, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary, height: 1.4),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withOpacity(0.4),
          disabledForegroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.6),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        prefixIconColor: Colors.grey.shade500,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: primary,
        labelStyle: const TextStyle(fontSize: 12, color: textPrimary),
        secondaryLabelStyle: const TextStyle(fontSize: 12, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
    );
  }
}
