import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/inventory_list.dart';
import 'pages/billing_dashboard.dart';
import 'pages/history_bill.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Billing App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // SplashScreen as the initial screen
      routes: {
        // Login route
        '/login': (context) => const InventoryLoginPage(),

        // Home route
        '/home': (context) => const HomePage(),

        // Inventory List route
        '/inventory': (context) => const InventoryList(),

        // Billing Dashboard route
        '/billing': (context) => const BillingDashboard(),

        '/history': (context)=> const HistoryBillsPage(),
      },
    );
  }
}
