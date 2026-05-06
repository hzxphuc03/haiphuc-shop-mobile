import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/order_service.dart';
import '../../data/models/order_model.dart';

class OrderListState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;

  OrderListState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderListState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OrderListNotifier extends StateNotifier<OrderListState> {
  final OrderService _service;
  OrderListNotifier(this._service) : super(OrderListState()) {
    fetchOrders(); // Initial fetch
  }

  Future<void> fetchOrders() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await _service.getMyOrders();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final orderServiceProvider = Provider((ref) => OrderService());
final orderListProvider = StateNotifierProvider<OrderListNotifier, OrderListState>((ref) {
  return OrderListNotifier(ref.watch(orderServiceProvider));
});
