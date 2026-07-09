import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

extension ThemeExtension on BuildContext {
  ThemeProvider get theme {
    try {
      return read<ThemeProvider>();
    } catch (_) {
      return ThemeProvider();
    }
  }

  Color get primary => theme.primaryColor;
  Color get primaryDark => theme.primaryDark;
  Color get accent => theme.accent;
  Color get accentLight => theme.accentLight;
  Color get appBackground => theme.background;
  Color get appSurface => theme.surface;
  Color get appSurfaceVariant => theme.surfaceVariant;
  Color get textPrimary => theme.textPrimary;
  Color get textSecondary => theme.textSecondary;
  Color get textHint => theme.textHint;
  Color get warning => theme.warning;
  Color get danger => theme.danger;
  Color get success => theme.success;
  LinearGradient get gradientPrimary => theme.gradientPrimary;
  List<Color> get cardColors => theme.cardColors;
}
