import 'product_model.dart';

class OrderModel {
  final String id;
  final String orderCode;
  final double totalAmount;
  final String status;
  final String? checkoutUrl;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderCode,
    required this.totalAmount,
    required this.status,
    this.checkoutUrl,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'],
      orderCode: json['orderCode'] ?? '',
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      checkoutUrl: json['checkoutUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['items'] as List).map((i) => OrderItemModel.fromJson(i)).toList(),
    );
  }
}

class OrderItemModel {
  final String productId;
  final int quantity;
  final double price;
  final String? size;
  final String? color;
  final String? imageUrl;

  OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
    this.size,
    this.color,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product'] is Map ? json['product']['_id'] : json['product'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      size: json['size'],
      color: json['color'],
      imageUrl: json['imageUrl'],
    );
  }
}
