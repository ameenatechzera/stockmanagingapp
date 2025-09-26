import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xffF5F7FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1243),
      elevation: 1,
    ),
  );

  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xff0A192F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1243),
      elevation: 1,
    ),
  );
}
