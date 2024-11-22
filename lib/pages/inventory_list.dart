import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddOrEditItemWidget extends StatefulWidget {
  final bool isEdit;
  final VoidCallback onClose;
  final Function(String name, String id, String price, String quantity, String description) onSave;
  final String? initialName;
  final String? initialID;
  final String? initialPrice;
  final String? initialQuantity;
  final String? initialDescription;

  const AddOrEditItemWidget({
    required this.isEdit,
    required this.onClose,
    required this.onSave,
    this.initialName,
    this.initialID,
    this.initialPrice,
    this.initialQuantity,
    this.initialDescription,
    super.key,
  });

  @override
  _AddOrEditItemWidgetState createState() => _AddOrEditItemWidgetState();
}

class _AddOrEditItemWidgetState extends State<AddOrEditItemWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _idController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _idController = TextEditingController(text: widget.initialID ?? '');
    _priceController = TextEditingController(text: widget.initialPrice ?? '');
    _quantityController = TextEditingController(text: widget.initialQuantity ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        _nameController.text.trim(),
        _idController.text.trim(),
        _priceController.text.trim(),
        _quantityController.text.trim(),
        _descriptionController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isEdit ? "Edit Item" : "Add Item",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Item Name"),
                  validator: (value) => value == null || value.isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(labelText: "Quantity"),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? "Quantity is required" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _idController,
                        decoration: const InputDecoration(labelText: "Item ID"),
                        validator: (value) => value == null || value.isEmpty ? "ID is required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? "Price is required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description (Optional)"),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.save),
                    label: Text(widget.isEdit ? "Save" : "Add"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InventoryList extends StatefulWidget {
  const InventoryList({super.key});

  @override
  _InventoryListState createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  final List<Map<String, dynamic>> _inventoryItems = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
  }

  Future<void> _loadInventoryItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedItems = prefs.getString('inventoryItems');
    if (storedItems != null) {
      setState(() {
        _inventoryItems.addAll(List<Map<String, dynamic>>.from(json.decode(storedItems)));
      });
    }
  }

  Future<void> _saveInventoryItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('inventoryItems', json.encode(_inventoryItems));
  }

  void _addOrUpdateItem(String name, String id, String price, String quantity, String description) {
    if (_editingIndex == null) {
      setState(() {
        _inventoryItems.add({
          'name': name,
          'id': id,
          'price': price,
          'quantity': quantity,
          'description': description,
        });
      });
    } else {
      setState(() {
        _inventoryItems[_editingIndex!] = {
          'name': name,
          'id': id,
          'price': price,
          'quantity': quantity,
          'description': description,
        };
        _editingIndex = null;
      });
    }
    _saveInventoryItems();
    Navigator.pop(context);
  }

  void _editItem(int index) {
    setState(() {
      _editingIndex = index;
    });
    final item = _inventoryItems[index];
    _showAddOrEditItemDialog(
      isEdit: true,
      initialName: item['name'],
      initialID: item['id'],
      initialPrice: item['price'],
      initialQuantity: item['quantity'],
      initialDescription: item['description'],
    );
  }

  void _removeItem(int index) {
    setState(() {
      _inventoryItems.removeAt(index);
    });
    _saveInventoryItems();
  }

  void _showAddOrEditItemDialog({
    bool isEdit = false,
    String? initialName,
    String? initialID,
    String? initialPrice,
    String? initialQuantity,
    String? initialDescription,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddOrEditItemWidget(
        isEdit: isEdit,
        onClose: () => Navigator.pop(context),
        onSave: _addOrUpdateItem,
        initialName: initialName,
        initialID: initialID,
        initialPrice: initialPrice,
        initialQuantity: initialQuantity,
        initialDescription: initialDescription,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory List'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body: _inventoryItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No items in inventory",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddOrEditItemDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Add Item"),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _inventoryItems.length,
              itemBuilder: (context, index) {
                final item = _inventoryItems[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ID: ${item['id']}"),
                        Text("Price: \$${item['price']}"),
                        Text("Quantity: ${item['quantity']}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editItem(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditItemDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: InventoryList()));
}
