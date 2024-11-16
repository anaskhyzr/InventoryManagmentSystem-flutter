import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ThemeMode currentThemeMode; // Add this line
  final Function(ThemeMode) onThemeChanged;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode, // Update constructor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF30C75E),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Change Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: currentThemeMode, // Use the current theme mode here
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Theme'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onThemeChanged(value);
                }
              },
            ),
          ),
          // Add more settings options as needed
          ListTile(
            title: const Text('About'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('About'),
                    content: const Text('This app is a simple inventory and billing system.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
