import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  final String size;
  final String color;
  final String type;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.size,
    required this.color,
    required this.type,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(ProductModel product, {required String size, required String color}) {
    final index = state.indexWhere((item) => 
      item.productId == product.id && item.size == size && item.color == color);
    
    String imageUrl = '';
    if (product.images.isNotEmpty) {
      imageUrl = product.images.firstWhere(
        (img) => img.color.toLowerCase() == color.toLowerCase(),
        orElse: () => product.images.first,
      ).url;
    }

    if (index >= 0) {
      state[index].quantity++;
      state = [...state];
    } else {
      state = [...state, CartItem(
        productId: product.id,
        name: product.name,
        price: product.priceVND,
        size: size,
        color: color,
        type: product.type,
        imageUrl: imageUrl,
      )];
    }
  }

  void updateQuantity(int index, int delta) {
    state[index].quantity += delta;
    if (state[index].quantity < 1) state[index].quantity = 1;
    state = [...state];
  }

  void removeFromCart(int index) {
    state = [...state]..removeAt(index);
  }

  void clear() {
    state = [];
  }

  double get totalAmount => state.fold(0, (sum, item) => sum + (item.price * item.quantity));

  Map<String, dynamic> buildOrderPayload({
    required double depositRate,
    required String paymentMethod,
  }) {
    return {
      'items': state.map((item) => {
        '_id': item.productId,
        'quantity': item.quantity,
        'size': item.size,
        'color': item.color,
        'priceVND': item.price,
        'type': item.type,
        'imageUrl': item.imageUrl,
      }).toList(),
      'depositRate': depositRate,
      'paymentMethod': paymentMethod == 'QR' ? 'QR_CODE' : 'COD',
    };
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

