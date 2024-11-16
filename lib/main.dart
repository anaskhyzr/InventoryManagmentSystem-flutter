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
  ThemeMode themeMode = ThemeMode.light; // Default theme

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
      // Set the initial route to the SplashScreen
      home: const SplashScreen(), // Set SplashScreen as initial screen
      routes: {
        '/login': (context) => const InventoryLoginPage(),
        '/home': (context) =>
            HomePage(onThemeChanged: setThemeMode, currentThemeMode: themeMode),
        '/settings': (context) => SettingsPage(
            onThemeChanged: setThemeMode, currentThemeMode: themeMode),
        '/inventory': (context) => InventoryList(
            onThemeChanged: setThemeMode, currentThemeMode: themeMode),
        '/billing': (context) => BillingDashboard(
            onThemeChanged: setThemeMode, currentThemeMode: themeMode),
      },
    );
  }
}
