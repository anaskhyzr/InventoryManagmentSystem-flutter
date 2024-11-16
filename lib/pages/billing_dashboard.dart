import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BillingDashboard extends StatefulWidget {
  final ThemeMode currentThemeMode;

  const BillingDashboard({super.key, required this.currentThemeMode, required void Function(ThemeMode mode) onThemeChanged});

  @override
  _BillingDashboardState createState() => _BillingDashboardState();
}

class _BillingDashboardState extends State<BillingDashboard> {
  final List<Map<String, dynamic>> _billingItems = [];
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();
  int _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadBillingItems();
  }

  Future<void> _loadBillingItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedItems = prefs.getString('billingItems');

    if (storedItems != null) {
      setState(() {
        _billingItems
            .addAll(List<Map<String, dynamic>>.from(json.decode(storedItems)));
      });
    }
  }

  Future<void> _saveBillingItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('billingItems', json.encode(_billingItems));
  }

  void _addItemToBill() async {
    String itemName = _itemNameController.text;
    String itemQuantity = _itemQuantityController.text;

    // Find item in inventory
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedItems = prefs.getString('inventoryItems');

    if (storedItems != null) {
      List<Map<String, dynamic>> inventoryItems =
          List<Map<String, dynamic>>.from(json.decode(storedItems));
      final inventoryItem = inventoryItems
          .firstWhere((item) => item['name'] == itemName, orElse: () => {});

      if (inventoryItem.isNotEmpty) {
        int availableQuantity = int.parse(inventoryItem['quantity']);
        int quantityToAdd = int.parse(itemQuantity);

        if (quantityToAdd > availableQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient quantity in inventory')),
          );
          return;
        }

        setState(() {
          _billingItems.add({
            'name': itemName,
            'quantity': itemQuantity,
            'price': inventoryItem['price'],
            'total': quantityToAdd * int.parse(inventoryItem['price']),
          });
          _totalAmount += quantityToAdd * int.parse(inventoryItem['price']);
        });

        // Update inventory
        availableQuantity -= quantityToAdd;
        inventoryItem['quantity'] = availableQuantity;

        // Save updated inventory back to local storage
        prefs.setString('inventoryItems', json.encode(inventoryItems));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item not found in inventory')),
        );
      }
    }

    _itemNameController.clear();
    _itemQuantityController.clear();
  }

  void _completeBill() {
    // Save the bill to local storage
    _saveBillingItems();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Bill completed!')));
    Navigator.pop(context); // Close the billing dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Dashboard'),
        backgroundColor: const Color(0xFF30C75E),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _itemQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItemToBill,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Total Amount: $_totalAmount PKR',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _billingItems.length,
              itemBuilder: (context, index) {
                final item = _billingItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text(
                      'Quantity: ${item['quantity']}, Total: ${item['total']} PKR'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _completeBill,
            child: const Text('Complete Bill'),
          ),
        ],
      ),
    );
  }
}
