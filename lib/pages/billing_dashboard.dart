import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BillingDashboard extends StatefulWidget {
  const BillingDashboard({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  @override
  _BillingDashboardState createState() => _BillingDashboardState();
}

class _BillingDashboardState extends State<BillingDashboard> {
  final List<Map<String, dynamic>> _billingItems = [];
  final TextEditingController _quantityController = TextEditingController();
  final List<Map<String, dynamic>> _inventoryItems = [];
  Map<String, dynamic>? _selectedItem;
  int _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  /// Load inventory from SharedPreferences
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

  /// Save updated inventory to SharedPreferences
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

  /// Add item to the bill
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
      // Ensure totalForItem is explicitly cast to int
      int totalForItem = (quantityToAdd * _selectedItem!['price']).toInt();
      _billingItems.add({
        'name': _selectedItem!['name'],
        'quantity': quantityToAdd,
        'price': _selectedItem!['price'],
        'total': totalForItem,
      });

      _totalAmount += totalForItem;

      // Update inventory
      _selectedItem!['quantity'] = availableQuantity - quantityToAdd;
    });

    _saveInventory();
    _quantityController.clear();
    _selectedItem = null;
  }

  /// Complete the bill and reset everything
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

  /// Toggle theme mode
  void _toggleTheme() {
    ThemeMode newThemeMode = widget.currentThemeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    widget.onThemeChanged(newThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Dashboard'),
        backgroundColor: const Color(0xFF30C75E),
        actions: [
          IconButton(
            icon: Icon(
              widget.currentThemeMode == ThemeMode.light
                  ? Icons.nightlight_round
                  : Icons.wb_sunny,
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown and Quantity Input
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedItem,
                    isExpanded: true,
                    hint: const Text('Select an Item'),
                    items: _inventoryItems
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              '${item['name']} (Available: ${item['quantity']})',
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
                    decoration: InputDecoration(
                      labelText: 'Quantity',
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
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total Amount
            Text(
              'Total Amount: $_totalAmount PKR',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Billing Items List
            Expanded(
              child: ListView.builder(
                itemCount: _billingItems.length,
                itemBuilder: (context, index) {
                  final item = _billingItems[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.receipt, color: Colors.green),
                      title: Text(item['name']),
                      subtitle: Text(
                        'Quantity: ${item['quantity']}, Price: ${item['price']} PKR, Total: ${item['total']} PKR',
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Complete Bill'),
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: BillingDashboard(
        onThemeChanged: (ThemeMode newThemeMode) {
          setState(() {
            _themeMode = newThemeMode;
          });
        },
        currentThemeMode: _themeMode,
      ),
    );
  }
}
