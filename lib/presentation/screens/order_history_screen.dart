import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order/order_provider.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Optimization: Never dispose this tab

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for KeepAlive

    final state = ref.watch(orderListProvider);

    if (state.isLoading && state.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD2FF1F)));
    }

    if (state.error != null && state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 16),
            const Text('Không thể tải đơn hàng', style: TextStyle(color: Colors.white70)),
            TextButton(
              onPressed: () => ref.read(orderListProvider.notifier).fetchOrders(),
              child: const Text('THỬ LẠI', style: TextStyle(color: Color(0xFFD2FF1F))),
            )
          ],
        ),
      );
    }

    if (state.orders.isEmpty) {
      return const Center(
        child: Text('Chưa có đơn hàng nào', style: TextStyle(color: Colors.white38, fontSize: 16)),
      );
    }

    return RepaintBoundary(
      child: RefreshIndicator(
        color: const Color(0xFFD2FF1F),
        onRefresh: () => ref.read(orderListProvider.notifier).fetchOrders(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: state.orders.length,
          itemBuilder: (context, index) {
            final order = state.orders[index];
            return _OrderListItem(order: order);
          },
        ),
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  final dynamic order;
  const _OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MÃ: ${order.orderCode}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
              _StatusTag(status: order.status),
            ],
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('• ${item.quantity}x Sản phẩm', style: const TextStyle(color: Colors.white70, fontSize: 13))),
                Text('${item.price.toInt()}đ', style: const TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          )).toList(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white10, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                style: const TextStyle(color: Colors.white24, fontSize: 11)),
              Text('${order.totalAmount.toInt()}đ',
                style: const TextStyle(color: Color(0xFFD2FF1F), fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String status;
  const _StatusTag({required this.status});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
