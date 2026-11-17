class ItemModel {
  const ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.status,
    required this.price,
    required this.rating,
    required this.description,
    required this.discountPercentage,
    required this.stock,
    required this.image,
  });

  final String id;
  final String name;
  final String category;
  final String brand;
  final String status;
  final double price;
  final double rating;
  final String description;
  final double discountPercentage;
  final int stock;
  final String image;

  String get subtitle => category;

  String get priceLabel => '\$${price.toStringAsFixed(2)}';

  String get discountLabel =>
      '${discountPercentage.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '')}%';

  List<MapEntry<String, String>> get detailAttributes => [
    MapEntry('Kategori', category),
    if (brand.isNotEmpty) MapEntry('Merek', brand),
    MapEntry('Harga', priceLabel),
    MapEntry('Rating', '${rating.toStringAsFixed(1)} / 5'),
    MapEntry('Deskripsi', description),
    MapEntry('Diskon', discountLabel),
    MapEntry('Stok', '$stock unit  ($status)'),
  ];

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final rawStock = json['stock'];
    final stock = rawStock is num
        ? rawStock.toInt()
        : int.tryParse('$rawStock') ?? 0;
    final rawStatus = (json['availabilityStatus'] ?? '').toString().trim();

    return ItemModel(
      id: (json['id'] ?? '').toString(),
      name: (json['title'] ?? json['name'] ?? 'Produk tanpa nama').toString(),
      category: (json['category'] ?? '-').toString(),
      brand: (json['brand'] ?? '').toString(),
      status: rawStatus.isNotEmpty
          ? rawStatus
          : stock <= 0
          ? 'Out of Stock'
          : stock <= 5
          ? 'Low Stock'
          : 'In Stock',
      price: _number(json['price']),
      rating: _number(json['rating']),
      description: (json['description'] ?? '-').toString(),
      discountPercentage: _number(json['discountPercentage']),
      stock: stock,
      image: (json['thumbnail'] ?? json['image'] ?? '').toString(),
    );
  }

  static double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': name,
    'category': category,
    'brand': brand,
    'availabilityStatus': status,
    'price': price,
    'rating': rating,
    'description': description,
    'discountPercentage': discountPercentage,
    'stock': stock,
    'thumbnail': image,
  };
}
