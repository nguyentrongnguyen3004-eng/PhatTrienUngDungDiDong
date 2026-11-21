class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId,
      name: map['name'] ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }
}
