import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _colorKey = 'app_primary_color';

  Color _primaryColor = const Color(0xFF1B6B3A);

  Color get primaryColor => _primaryColor;
  Color get primaryDark => _darken(_primaryColor, 0.15);
  Color get accent => _lighten(_primaryColor, 0.25);
  Color get accentLight => _lighten(_primaryColor, 0.45);
  Color get background => _lighten(_primaryColor, 0.92);
  Color get surface => Colors.white;
  Color get surfaceVariant => _lighten(_primaryColor, 0.88);
  Color get textPrimary => _darken(_primaryColor, 0.2);
  Color get textSecondary => _darken(_primaryColor, 0.35);
  Color get textHint => _lighten(_primaryColor, 0.3);

  Color get success => const Color(0xFF1F8A4F);
  Color get danger => const Color(0xFFC0392B);
  Color get warning => const Color(0xFFD9982E);

  LinearGradient get gradientPrimary => LinearGradient(
        colors: [_primaryColor, primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get gradientAccent => LinearGradient(
        colors: [accent, _primaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get gradientWarm => LinearGradient(
        colors: [const Color(0xFFD9982E), const Color(0xFFC0392B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  List<Color> get cardColors => [
        _primaryColor,
        accent,
        const Color(0xFFD9982E),
        const Color(0xFFC0392B),
        const Color(0xFF1F8A4F),
        accentLight,
      ];

  static const List<AppColorOption> colorOptions = [
    AppColorOption(
      name: 'Xanh lá',
      primary: Color(0xFF1B6B3A),
      background: Color(0xFFF1F7F4),
    ),
    AppColorOption(
      name: 'Xanh dương',
      primary: Color(0xFF1565C0),
      background: Color(0xFFF0F4F8),
    ),
    AppColorOption(
      name: 'Tím',
      primary: Color(0xFF6A1B9A),
      background: Color(0xFFF5F0F8),
    ),
    AppColorOption(
      name: 'Cam',
      primary: Color(0xFFE65100),
      background: Color(0xFFFFF3E0),
    ),
    AppColorOption(
      name: 'Đỏ',
      primary: Color(0xFFC62828),
      background: Color(0xFFFFEBEE),
    ),
    AppColorOption(
      name: 'Hồng',
      primary: Color(0xFFAD1457),
      background: Color(0xFFFCE4EC),
    ),
    AppColorOption(
      name: 'Nâu',
      primary: Color(0xFF5D4037),
      background: Color(0xFFEFEBE9),
    ),
    AppColorOption(
      name: 'Xám',
      primary: Color(0xFF37474F),
      background: Color(0xFFECEFF1),
    ),
  ];

  ThemeProvider() {
    _loadColor();
  }

  Future<void> _loadColor() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColor = prefs.getInt(_colorKey);
    if (savedColor != null) {
      _primaryColor = Color(savedColor);
      notifyListeners();
    }
  }

  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor == color) return;
    _primaryColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.toARGB32());
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        primary: _primaryColor,
        secondary: accent,
        surface: surface,
        error: const Color(0xFFC0392B),
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: BorderSide(color: _primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
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
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC0392B), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC0392B), width: 2),
        ),
        labelStyle: TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: textHint, fontSize: 14),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const StadiumBorder(),
      ),
      dividerTheme: DividerThemeData(
        color: textHint.withValues(alpha: 0.2),
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: _primaryColor,
        unselectedItemColor: textHint,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

class AppColorOption {
  final String name;
  final Color primary;
  final Color background;

  const AppColorOption({
    required this.name,
    required this.primary,
    required this.background,
  });
}
