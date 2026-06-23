import 'package:flutter/material.dart';

class ThemeManager {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0077B6),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0077B6),
      secondary: Color(0xFF00B4D8),
    ),
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: Colors.white,
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF0077B6),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0077B6),
      secondary: Color(0xFF00B4D8),
    ),
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: const Color(0xFF121212),
  );
}
