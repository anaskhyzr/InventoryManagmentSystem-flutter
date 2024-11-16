import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome(); // Call the navigation method
  }

  // Method to navigate to the home page after a delay
  Future<void> _navigateToHome() async {
    await Future.delayed(
        const Duration(seconds: 3)); // Change the duration as needed
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              const InventoryLoginPage()), // Adjust accordingly
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/appIcon.png', height: 100), // Your app icon
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ), // Loading indicator
          ],
        ),
      ),
    );
  }
}
