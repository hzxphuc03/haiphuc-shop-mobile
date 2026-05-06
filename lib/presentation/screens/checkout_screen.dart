import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/cart/cart_provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../data/services/order_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _paymentMethod = 'QR'; // Default to QR
  double _depositRate = 1.0; // Default to 100%
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.fullName ?? '';
      _phoneController.text = user.phone ?? '';
    }
    
    // Auto-set deposit rate for ORDER items
    final cartItems = ref.read(cartProvider);
    final hasOrderType = cartItems.any((item) => item.type == 'ORDER');
    if (hasOrderType) {
      _depositRate = 0.7; // Default 70% for ORDER
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);
    try {
      final user = ref.read(authProvider).user;
      final cartNotifier = ref.read(cartProvider.notifier);
      final orderData = cartNotifier.buildOrderPayload(
        depositRate: _depositRate,
        paymentMethod: _paymentMethod,
      );

      // Add contact and user info directly to the root
      orderData.addAll({
        'user': user != null ? user.fullName : 'Guest',
        'fullName': _nameController.text,
        'phoneNumber': _phoneController.text,
        'email': user?.email ?? 'guest@haiphuc.com',
        'address': _addressController.text,
      });

      final order = await OrderService().createOrder(orderData);
      
      if (_paymentMethod == 'QR' && order.checkoutUrl != null) {
        final url = Uri.parse(order.checkoutUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }

      ref.read(cartProvider.notifier).clear();
      if (mounted) {
        context.go('/orders');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final hasOrderType = cartItems.any((item) => item.type == 'ORDER');
    final total = ref.watch(cartProvider.notifier).totalAmount;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('THANH TOÁN')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('THÔNG TIN GIAO HÀNG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(_nameController, 'Họ và tên'),
            const SizedBox(height: 15),
            _buildTextField(_phoneController, 'Số điện thoại'),
            const SizedBox(height: 15),
            _buildTextField(_addressController, 'Địa chỉ nhận hàng', maxLines: 2),
            const SizedBox(height: 30),
            
            const Text('PHƯƠNG THỨC THANH TOÁN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (!hasOrderType) ...[
              _buildPaymentOption('COD', 'Thanh toán khi nhận hàng'),
              _buildPaymentOption('QR', 'Chuyển khoản VietQR (PayOS)'),
            ] else ...[
              _buildPaymentOption('QR', 'Chuyển khoản đặt cọc (PayOS)'),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('Mức đặt cọc:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              Row(
                children: [
                  _buildDepositOption(0.7, '70%'),
                  const SizedBox(width: 20),
                  _buildDepositOption(1.0, '100%'),
                ],
              ),
            ],

            const SizedBox(height: 40),
            _buildSummary(total),
            const SizedBox(height: 20),
            if (isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD2FF1F), foregroundColor: Colors.black),
                  child: const Text('XÁC NHẬN ĐẶT HÀNG', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD2FF1F))),
      ),
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? 'Vui lòng điền thông tin' : null,
    );
  }

  Widget _buildPaymentOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      value: value,
      groupValue: _paymentMethod,
      onChanged: (v) => setState(() => _paymentMethod = v!),
      activeColor: const Color(0xFFD2FF1F),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDepositOption(double value, String label) {
    return Row(
      children: [
        Radio<double>(
          value: value,
          groupValue: _depositRate,
          onChanged: (v) => setState(() => _depositRate = v!),
          activeColor: const Color(0xFFD2FF1F),
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildSummary(double total) {
    final deposit = total * _depositRate;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _buildRow('Tổng cộng', '${total.toInt()} VND'),
          if (_depositRate < 1.0) ...[
            const SizedBox(height: 5),
            _buildRow('Cần thanh toán trước (${(_depositRate * 100).toInt()}%)', '${deposit.toInt()} VND', isBold: true),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: Colors.white, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

