import 'dart:ui';
import 'package:flutter/material.dart';

class AppColors {
  // Darker green palette
  static const primary = Color(0xFF1B6B3A);
  static const primaryDark = Color(0xFF143D22);
  static const accent = Color(0xFF2E8B5A);
  static const accentLight = Color(0xFF4DA87A);
  static const warning = Color(0xFFD9982E);
  static const danger = Color(0xFFC0392B);
  static const success = Color(0xFF1F8A4F);

  static const background = Color(0xFFF1F7F4);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFE6F2EC);

  static const textPrimary = Color(0xFF143D22);
  static const textSecondary = Color(0xFF3E6650);
  static const textHint = Color(0xFF8AA898);

  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF1B6B3A), Color(0xFF143D22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientAccent = LinearGradient(
    colors: [Color(0xFF2E8B5A), Color(0xFF1B6B3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientWarm = LinearGradient(
    colors: [Color(0xFFD9982E), Color(0xFFC0392B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get glassGradient => const LinearGradient(
    colors: [Color(0xFFE6F2EC), Color(0xFFF1F7F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: const Color(0xFF1B6B3A).withValues(alpha: 0.12),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.55),
      blurRadius: 10,
      offset: const Offset(-5, -5),
    ),
  ];

  static List<BoxShadow> get glassShadowStrong => [
    BoxShadow(
      color: const Color(0xFF1B6B3A).withValues(alpha: 0.18),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.6),
      blurRadius: 14,
      offset: const Offset(-8, -8),
    ),
  ];

  static const List<Color> cardColors = [
    Color(0xFF1B6B3A),
    Color(0xFF2E8B5A),
    Color(0xFFD9982E),
    Color(0xFFC0392B),
    Color(0xFF1F8A4F),
    Color(0xFF4DA87A),
  ];
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: StadiumBorder(),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEF0F6),
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    ),
  );
}
