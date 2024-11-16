import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryBillsPage extends StatefulWidget {
  const HistoryBillsPage({super.key});

  @override
  _HistoryBillsPageState createState() => _HistoryBillsPageState();
}

class _HistoryBillsPageState extends State<HistoryBillsPage> {
  final List<Map<String, dynamic>> _historyBills = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryBills();
  }

  // Load history bills from SharedPreferences
  Future<void> _loadHistoryBills() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedBills = prefs.getString('historyBills');

    if (storedBills != null && storedBills.isNotEmpty) {
      setState(() {
        _historyBills.addAll(List<Map<String, dynamic>>.from(json.decode(storedBills)));
      });
    } else {
      // Handle case when no history bills are found
      setState(() {
        _historyBills.clear(); // Clear the list if no data is found
      });
    }
  }

  // Save updated history bills to SharedPreferences
  Future<void> _saveHistoryBills() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('historyBills', json.encode(_historyBills));
  }

  // Remove a bill from history
  void _removeBill(int index) {
    setState(() {
      _historyBills.removeAt(index);
    });
    _saveHistoryBills(); // Update local storage
  }

  // Restore bill to inventory
  void _restoreBill(int index) async {
    final bill = _historyBills[index];

    // Load current inventory
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedItems = prefs.getString('inventoryItems');

    List<Map<String, dynamic>> inventoryItems = [];
    if (storedItems != null && storedItems.isNotEmpty) {
      inventoryItems = List<Map<String, dynamic>>.from(json.decode(storedItems));
    }

    // Check if item already exists in inventory
    final inventoryItem = inventoryItems.firstWhere(
      (item) => item['name'] == bill['name'],
      orElse: () => {},
    );

    if (inventoryItem.isNotEmpty) {
      inventoryItem['quantity'] = (int.parse(inventoryItem['quantity']) + int.parse(bill['quantity'])).toString();
    } else {
      // If not present, add it to inventory
      inventoryItems.add({
        'name': bill['name'],
        'price': bill['price'],
        'quantity': bill['quantity'],
        'description': bill['description'],
      });
    }

    // Update local storage with the updated inventory
    prefs.setString('inventoryItems', json.encode(inventoryItems));

    // Remove from history bills
    _removeBill(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Bills'),
        backgroundColor: const Color(0xFF30C75E),
      ),
      body: _historyBills.isEmpty
          ? const Center(child: Text('No history bills available'))
          : ListView.builder(
              itemCount: _historyBills.length,
              itemBuilder: (context, index) {
                final bill = _historyBills[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(bill['name']),
                    subtitle: Text('Total: ${bill['total']} PKR, Date: ${bill['date']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore),
                          onPressed: () => _restoreBill(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeBill(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
