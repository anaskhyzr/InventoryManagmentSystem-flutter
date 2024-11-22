import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management System'),
        backgroundColor: const Color(0xFF30C75E),
      ),
      backgroundColor: const Color.fromARGB(255, 27, 27, 27), // Set the background color to black
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Ensure the text is visible on black
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMenuButton(
                        context,
                        label: 'Inventory',
                        icon: Icons.inventory,
                        route: '/inventory',
                      ),
                      _buildMenuButton(
                        context,
                        label: 'Dashboard',
                        icon: Icons.dashboard,
                        route: '/billing',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMenuButton(
                        context,
                        label: 'History Bills',
                        icon: Icons.history,
                        route: '/history', 
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String label, required IconData icon, required String route}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(label),
      onPressed: () {
        // Navigate to the route
        Navigator.pushNamed(context, route);
      },
    );
  }
}
