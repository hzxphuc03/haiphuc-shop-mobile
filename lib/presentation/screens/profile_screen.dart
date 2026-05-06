import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('TÀI KHOẢN', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: user == null 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFD2FF1F),
                  child: Icon(Icons.person, size: 50, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(user.fullName ?? 'User', 
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: Text(user.email, style: const TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 40),
              _buildMenuItem(Icons.shopping_bag_outlined, 'Đơn hàng của tôi', () => context.push('/orders')),
              _buildMenuItem(Icons.favorite_border, 'Sản phẩm yêu thích', () {}),
              _buildMenuItem(Icons.location_on_outlined, 'Địa chỉ giao hàng', () {}),
              _buildMenuItem(Icons.settings_outlined, 'Cài đặt', () {}),
              const SizedBox(height: 40),
              const Text('HỖ TRỢ', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              _buildMenuItem(Icons.help_outline, 'Trung tâm trợ giúp', () {}),
              _buildMenuItem(Icons.info_outline, 'Về Haiphuc Shop', () {}),
            ],
          ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Đăng xuất?', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY')),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context);
              context.go('/login');
            }, 
            child: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}
