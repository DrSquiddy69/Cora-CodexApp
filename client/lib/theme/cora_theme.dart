import 'package:flutter/material.dart';

class CoraTokens {
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double borderAlpha = 0.1;
}

ThemeData buildCoraTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3ED9FF),
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CoraTokens.radiusMd),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: CoraTokens.borderAlpha)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CoraTokens.radiusMd),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: CoraTokens.borderAlpha)),
      ),
    ),
  );
}
