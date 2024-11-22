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

  Future<void> _loadHistoryBills() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedBills = prefs.getString('historyBills');
    if (storedBills != null && storedBills.isNotEmpty) {
      setState(() {
        _historyBills.addAll(List<Map<String, dynamic>>.from(json.decode(storedBills)));
      });
    }
  }

  Future<void> _deleteBill(int index) async {
    setState(() {
      _historyBills.removeAt(index);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('historyBills', json.encode(_historyBills));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Bills'),
        backgroundColor: const Color(0xFF30C75E),
      ),
      backgroundColor: const Color.fromARGB(255, 27, 27, 27),
      body: _historyBills.isEmpty
          ? const Center(
              child: Text(
                'No history bills available.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _historyBills.length,
              itemBuilder: (context, index) {
                final bill = _historyBills[index];
                final formattedDate = DateTime.parse(bill['date']).toLocal().toString().split(' ')[0];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('Bill Date: $formattedDate'),
                    subtitle: Text('Total Amount: ${bill['total']} PKR'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color.fromARGB(255, 247, 247, 247)),
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Confirmation'),
                              content: const Text('Are you sure you want to delete this bill?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          _deleteBill(index);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
