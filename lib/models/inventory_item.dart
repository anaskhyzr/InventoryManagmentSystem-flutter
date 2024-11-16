class InventoryItem {
  String name;
  int quantity;
  double price;

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  static InventoryItem fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
