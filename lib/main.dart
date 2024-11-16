import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/splash_screen.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/settings.dart';
import 'pages/inventory_list.dart';
import 'pages/billing_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light; // Default theme mode

  void setThemeMode(ThemeMode mode) {
    setState(() {
      themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Billing App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      // Set SplashScreen as the initial screen
      home: const SplashScreen(),
      routes: {
        // Login route
        '/login': (context) => const InventoryLoginPage(),

        // Home route
        '/home': (context) => HomePage(
              onThemeChanged: setThemeMode,
              currentThemeMode: themeMode,
            ),

        // Settings route
        '/settings': (context) => SettingsPage(
              onThemeChanged: setThemeMode,
              currentThemeMode: themeMode,
            ),

        // Inventory List route
        '/inventory': (context) => InventoryList(
              onThemeChanged: setThemeMode,
              currentThemeMode: themeMode,
            ),

        // Billing Dashboard route
        '/billing': (context) => BillingDashboard(
              onThemeChanged: setThemeMode,
              currentThemeMode: themeMode,
            ),
      },
    );
  }
}
