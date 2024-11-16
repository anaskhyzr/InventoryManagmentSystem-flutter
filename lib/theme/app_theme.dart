import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primarySwatch: Colors.green,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.green,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: Colors.black, fontSize: 20), // For titles
        bodyLarge: TextStyle(color: Colors.black),    // Previously bodyText1
        bodyMedium: TextStyle(color: Colors.black54), // Previously bodyText2
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.green,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      primarySwatch: Colors.green,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.green[800],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: Colors.white, fontSize: 20), // For titles
        bodyLarge: TextStyle(color: Colors.white),     // Previously bodyText1
        bodyMedium: TextStyle(color: Colors.white54),  // Previously bodyText2
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.green,
      ),
    );
  }
}
