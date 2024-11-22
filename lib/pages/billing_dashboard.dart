import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BillingDashboard extends StatefulWidget {
  const BillingDashboard({super.key});

  @override
  _BillingDashboardState createState() => _BillingDashboardState();
}

class _BillingDashboardState extends State<BillingDashboard> {
  final List<Map<String, dynamic>> _billingItems = [];
  final TextEditingController _quantityController = TextEditingController();
  final List<Map<String, dynamic>> _inventoryItems = [];
  Map<String, dynamic>? _selectedItem;
  num _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedInventory = prefs.getString('inventoryItems');

    if (storedInventory != null) {
      setState(() {
        _inventoryItems.addAll(
          List<Map<String, dynamic>>.from(
            json.decode(storedInventory).map((item) => {
                  'name': item['name'],
                  'quantity': int.tryParse(item['quantity'].toString()) ?? 0,
                  'price': int.tryParse(item['price'].toString()) ?? 0,
                  'description': item['description'] ?? '',
                }),
          ),
        );
      });
    }
  }

  Future<void> _saveInventory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'inventoryItems',
      json.encode(
        _inventoryItems.map((item) => {
              'name': item['name'],
              'quantity': item['quantity'].toString(),
              'price': item['price'].toString(),
              'description': item['description'] ?? '',
            }).toList(),
      ),
    );
  }

  void _addItemToBill() {
    if (_selectedItem == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item and enter a quantity.')),
      );
      return;
    }

    int quantityToAdd = int.tryParse(_quantityController.text) ?? 0;
    int availableQuantity = _selectedItem!['quantity'];

    if (quantityToAdd > availableQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient quantity in inventory.')),
      );
      return;
    }

    setState(() {
      num totalForItem = quantityToAdd * _selectedItem!['price'];
      _billingItems.add({
        'name': _selectedItem!['name'],
        'quantity': quantityToAdd,
        'price': _selectedItem!['price'],
        'total': totalForItem,
      });

      _totalAmount += totalForItem;
      _selectedItem!['quantity'] = availableQuantity - quantityToAdd;
    });

    _saveInventory();
    _quantityController.clear();
    _selectedItem = null;
  }

  void _completeBill() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> historyBills = [];
    String? storedHistory = prefs.getString('historyBills');

    if (storedHistory != null) {
      historyBills = List<Map<String, dynamic>>.from(json.decode(storedHistory));
    }

    historyBills.add({
      'items': _billingItems,
      'total': _totalAmount,
      'date': DateTime.now().toIso8601String(),
    });

    await prefs.setString('historyBills', json.encode(historyBills));

    setState(() {
      _billingItems.clear();
      _totalAmount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill completed and saved to history!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text('Billing Dashboard'),
        backgroundColor: const Color(0xFF30C75E),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown and Quantity Input
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedItem,
                    isExpanded: true,
                    hint: const Text(
                      'Select an Item',
                      style: TextStyle(color: Colors.white),
                    ),
                    dropdownColor: Colors.grey[850],
                    items: _inventoryItems
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              '${item['name']} (Available: ${item['quantity']})',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedItem = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2C2C2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addItemToBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total Amount
            Text(
              'Total Amount: $_totalAmount PKR',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Billing Items List
            Expanded(
              child: _billingItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No items in the bill',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _billingItems.length,
                      itemBuilder: (context, index) {
                        final item = _billingItems[index];
                        return Card(
                          color: const Color(0xFF2C2C2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.receipt, color: Colors.green),
                            title: Text(item['name'], style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              'Quantity: ${item['quantity']}, Price: ${item['price']} PKR, Total: ${item['total']} PKR',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Complete Bill Button
            ElevatedButton(
              onPressed: _completeBill,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Center(
                child: Text('Complete Bill', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BillingDashboard(),
    ),
  );
}
