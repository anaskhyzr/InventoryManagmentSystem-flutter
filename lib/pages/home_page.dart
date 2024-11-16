import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/history_bill.dart';
import 'package:flutter_application_1/pages/settings.dart';
import 'inventory_list.dart';
import 'billing_dashboard.dart'; // Import the billing dashboard
// Import the history bills page

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: HomePage(
        currentThemeMode: _themeMode,
        onThemeChanged: _setTheme,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;

  const HomePage(
      {super.key,
      required this.currentThemeMode,
      required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: const Color(0xFF30C75E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryList(
                        onThemeChanged: onThemeChanged,
                        currentThemeMode: currentThemeMode),
                  ),
                );
              },
              child: const Text('Manage Inventory'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BillingDashboard(
                      currentThemeMode: currentThemeMode,
                      onThemeChanged: (ThemeMode mode) {},
                    ),
                  ),
                );
              },
              child: const Text('Billing Dashboard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryBillsPage(),
                  ),
                );
              },
              child: const Text('History Bills'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                        onThemeChanged: onThemeChanged,
                        currentThemeMode: currentThemeMode),
                  ),
                );
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
