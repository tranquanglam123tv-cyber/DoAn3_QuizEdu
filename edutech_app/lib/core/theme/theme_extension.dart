import 'package:flutter/material.dart';
import 'theme_provider.dart';

extension ThemeExtension on BuildContext {
  ThemeProvider get theme => ThemeProvider();

  Color get primary => readTheme.primaryColor;
  Color get primaryDark => readTheme.primaryDark;
  Color get accent => readTheme.accent;
  Color get accentLight => readTheme.accentLight;
  Color get appBackground => readTheme.background;
  Color get appSurface => readTheme.surface;
  Color get appSurfaceVariant => readTheme.surfaceVariant;
  Color get textPrimary => readTheme.textPrimary;
  Color get textSecondary => readTheme.textSecondary;
  Color get textHint => readTheme.textHint;
  Color get warning => readTheme.warning;
  Color get danger => readTheme.danger;
  Color get success => readTheme.success;
  LinearGradient get gradientPrimary => readTheme.gradientPrimary;
  List<Color> get cardColors => readTheme.cardColors;
}

extension ThemeProviderGetter on BuildContext {
  ThemeProvider get readTheme {
    try {
      // ignore: unnecessary_cast
      return (this as dynamic).read<ThemeProvider>();
    } catch (_) {
      return ThemeProvider();
    }
  }
}
