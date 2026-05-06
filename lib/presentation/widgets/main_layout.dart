import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart/cart_provider.dart';
import '../../providers/product/product_provider.dart';

class MainLayout extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainLayout({super.key, required this.navigationShell});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != oldWidget.navigationShell.currentIndex) {
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'HAIPHUC SHOP';
      case 1: return 'ĐƠN HÀNG';
      case 2: return 'GIỎ HÀNG';
      case 3: return 'TÀI KHOẢN';
      default: return 'HAIPHUC SHOP';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider).length;
    final selectedIndex = widget.navigationShell.currentIndex;
    final isHome = selectedIndex == 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: !isHome,
        leading: isHome ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _onItemTapped(0),
        ),
        title: _isSearching && isHome
          ? TextField(
              controller: _searchController,
              autofocus: true,
              keyboardType: TextInputType.text,
              enableSuggestions: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                ref.read(productListProvider.notifier).setSearch(value);
              },
            )
          : Text(_getTitle(selectedIndex), 
              style: TextStyle(
                fontWeight: isHome ? FontWeight.w900 : FontWeight.bold, 
                letterSpacing: isHome ? 2 : 0, 
                fontStyle: isHome ? FontStyle.italic : FontStyle.normal,
                fontSize: isHome ? 20 : 16,
              )),
        actions: [
          if (isHome) IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  ref.read(productListProvider.notifier).setSearch(null);
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          if (!_isSearching && isHome) _buildCartBadge(context, cartCount),
        ],
      ),
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFD2FF1F),
        unselectedItemColor: Colors.white38,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'TRANG CHỦ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'ĐƠN HÀNG'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'GIỎ HÀNG'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'TÔI'),
        ],
      ),
    );
  }

  Widget _buildCartBadge(BuildContext context, int count) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined),
          onPressed: () => _onItemTapped(2),
        ),
        if (count > 0)
          Positioned(
            right: 8, top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Color(0xFFD2FF1F), shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text('$count', 
                style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }
}
