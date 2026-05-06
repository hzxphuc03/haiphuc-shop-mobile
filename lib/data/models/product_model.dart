class ProductModel {
  final String id;
  final String name;
  final String description;
  final double priceVND;
  final String category;
  final List<String> sizes;
  final List<String> colors;
  final List<ProductImage> images;
  final String type;
  final bool isSale;

  // Optimization: Pre-computed fields to save UI thread cycles
  late final String displayName;
  late final String displayPrice;
  late final String displayCategory;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceVND,
    required this.category,
    required this.sizes,
    required this.colors,
    required this.images,
    required this.type,
    required this.isSale,
  }) {
    // Pre-compute during object creation, NOT during build()
    displayName = name.toUpperCase();
    displayPrice = '${priceVND.toInt()}đ';
    displayCategory = category.toUpperCase();
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'] ?? '',
      priceVND: (json['priceVND'] as num).toDouble(),
      category: json['category'],
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      images: (json['images'] as List).map((i) => ProductImage.fromJson(i)).toList(),
      type: json['type'] ?? 'READY',
      isSale: json['isSale'] ?? false,
    );
  }
}

class ProductImage {
  final String url;
  final String color;

  ProductImage({required this.url, required this.color});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'],
      color: json['color'] ?? 'All',
    );
  }
}
