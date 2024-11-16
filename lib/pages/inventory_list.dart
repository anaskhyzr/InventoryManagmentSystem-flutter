import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InventoryList extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  const InventoryList({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  _InventoryListState createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  final List<Map<String, dynamic>> _inventoryItems = [];
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController(); // Description controller
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadInventoryItems(); // Load items from local storage when the app starts
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _itemQuantityController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  // Load inventory items from local storage
  Future<void> _loadInventoryItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedItems = prefs.getString('inventoryItems');

    if (storedItems != null) {
      setState(() {
        _inventoryItems.addAll(List<Map<String, dynamic>>.from(json.decode(storedItems)));
      });
    }
  }

  // Save the inventory list to local storage
  Future<void> _saveInventoryItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('inventoryItems', json.encode(_inventoryItems));
  }

  // Add or update an inventory item
  void _addOrUpdateItem() {
    String itemName = _itemNameController.text;
    String itemPrice = _itemPriceController.text;
    String itemQuantity = _itemQuantityController.text;
    String itemDescription = _itemDescriptionController.text;

    if (itemName.isEmpty || itemPrice.isEmpty || itemQuantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    DateTime now = DateTime.now(); // Get current date and time
    String dateTimeAdded = now.toIso8601String(); // Format the date and time

    if (_editingIndex == null) {
      // Add new item
      setState(() {
        _inventoryItems.add({
          'name': itemName,
          'price': itemPrice,
          'quantity': itemQuantity,
          'description': itemDescription,
          'dateTimeAdded': dateTimeAdded, // Store the date and time added
        });
      });
    } else {
      // Update existing item
      setState(() {
        _inventoryItems[_editingIndex!] = {
          'name': itemName,
          'price': itemPrice,
          'quantity': itemQuantity,
          'description': itemDescription,
          'dateTimeAdded': dateTimeAdded,
        };
        _editingIndex = null;
      });
    }

    _saveInventoryItems(); // Save updated inventory to local storage

    _itemNameController.clear();
    _itemPriceController.clear();
    _itemQuantityController.clear();
    _itemDescriptionController.clear(); // Clear description field
    Navigator.pop(context); // Close the bottom sheet after saving
  }

  // Show the bottom sheet to add or edit an item
  void _showAddOrEditItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.currentThemeMode == ThemeMode.dark ? Colors.black87 : Colors.white, // Dynamic background
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: TextStyle(
                    color: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
                  ),
                ),
                style: TextStyle(
                  color: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
                ),
              ),
              TextField(
                controller: _itemPriceController,
                decoration: InputDecoration(
                  labelText: 'Item Price (PKR)',
                  labelStyle: TextStyle(
                    color: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
                ),
              ),
              TextField(
                controller: _itemQuantityController,
                decoration: InputDecoration(
                  labelText: 'Item Quantity',
                  labelStyle: TextStyle(
                    color: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
                ),
              ),
              TextField(
                controller: _itemDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Item Description (optional)',
                  labelStyle: TextStyle(
                    color: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
                  ),
                ),
                style: TextStyle(
                  color: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addOrUpdateItem,
                child: Text(_editingIndex == null ? 'Add Item' : 'Update Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Edit the selected inventory item
  void _editItem(int index) {
    setState(() {
      _editingIndex = index;
      _itemNameController.text = _inventoryItems[index]['name'];
      _itemPriceController.text = _inventoryItems[index]['price'];
      _itemQuantityController.text = _inventoryItems[index]['quantity'];
      _itemDescriptionController.text = _inventoryItems[index]['description'] ?? ''; // Optional
    });
    _showAddOrEditItemSheet();
  }

  // Remove the selected inventory item
  void _removeItem(int index) {
    setState(() {
      _inventoryItems.removeAt(index);
    });
    _saveInventoryItems(); // Update local storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory List'),
        backgroundColor: const Color(0xFF30C75E),
      ),
      body: ListView.builder(
        itemCount: _inventoryItems.length,
        itemBuilder: (context, index) {
          final item = _inventoryItems[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text('Price: ${item['price']} PKR, Quantity: ${item['quantity']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editItem(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            onTap: () => _editItem(index), // Edit on tap
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOrEditItemSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
