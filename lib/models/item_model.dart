// item_model.dart

class Item {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String sellerId;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.sellerId,
  });

  factory Item.fromMap(String id, Map<String, dynamic> data) {
    return Item(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      sellerId: data['sellerId'] ?? '',
    );
  }
}