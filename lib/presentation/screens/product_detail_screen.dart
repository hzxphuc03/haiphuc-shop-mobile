import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart/cart_provider.dart';
import '../../data/models/product_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> with SingleTickerProviderStateMixin {
  String? selectedSize;
  String? selectedColor;
  bool isDescriptionExpanded = false;
  int currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onColorSelected(String color) {
    if (selectedColor == color) return;
    setState(() => selectedColor = color);
    
    final colorIndex = widget.product.images.indexWhere(
      (img) => img.color.toLowerCase() == color.toLowerCase()
    );
    
    if (colorIndex != -1) {
      _pageController.animateToPage(
        colorIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic, // Optimization: Smoother curve for lower-end devices
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSizes = widget.product.sizes.isNotEmpty;
    final hasColors = widget.product.colors.isNotEmpty;
    final canAddToCart = (!hasSizes || selectedSize != null) && (!hasColors || selectedColor != null);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      if (hasSizes) ...[
                        const _SectionTitle(title: 'CHỌN KÍCH CỠ'),
                        const SizedBox(height: 12),
                        _buildVariationSelector(
                          items: widget.product.sizes,
                          selectedItem: selectedSize,
                          onSelect: (val) => setState(() => selectedSize = val),
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (hasColors) ...[
                        const _SectionTitle(title: 'CHỌN MÀU SẮC'),
                        const SizedBox(height: 12),
                        _buildVariationSelector(
                          items: widget.product.colors,
                          selectedItem: selectedColor,
                          onSelect: _onColorSelected,
                        ),
                        const SizedBox(height: 32),
                      ],
                      _buildDescription(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _BottomActionBar(canAction: canAddToCart, product: widget.product, selectedSize: selectedSize, selectedColor: selectedColor),
          const _BackButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.45,
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => currentImageIndex = index),
              itemCount: widget.product.images.length,
              itemBuilder: (context, index) => CachedNetworkImage(
                imageUrl: widget.product.images[index].url,
                fit: BoxFit.cover,
                // Optimization: Limit image decode size to avoid memory overflow
                memCacheHeight: 800, 
                placeholder: (context, url) => Container(color: Colors.grey[900]),
              ),
            ),
            _ImageIndicator(count: widget.product.images.length, currentIndex: currentImageIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.product.category.toUpperCase(), 
              style: const TextStyle(color: Color(0xFFD2FF1F), fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
            Text(widget.product.type.toUpperCase(), 
              style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Text(widget.product.name.toUpperCase(), 
          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 1.1)),
        const SizedBox(height: 16),
        Text('${widget.product.priceVND.toInt()}đ', 
          style: const TextStyle(color: Color(0xFFD2FF1F), fontSize: 30, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildVariationSelector({
    required List<String> items,
    required String? selectedItem,
    required Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isSelected = selectedItem == item;
        return InkWell(
          onTap: () => onSelect(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD2FF1F) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isSelected ? const Color(0xFFD2FF1F) : Colors.white10),
            ),
            child: Text(item, 
              style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'MÔ TẢ CHI TIẾT'),
        const SizedBox(height: 12),
        Text(
          widget.product.description,
          maxLines: isDescriptionExpanded ? null : 4,
          overflow: isDescriptionExpanded ? null : TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() => isDescriptionExpanded = !isDescriptionExpanded),
          child: Text(
            isDescriptionExpanded ? 'THU GỌN ▲' : 'XEM THÊM ▼',
            style: const TextStyle(color: Color(0xFFD2FF1F), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1));
  }
}

class _ImageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  const _ImageIndicator({required this.count, required this.currentIndex});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20, left: 0, right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: currentIndex == index ? 20 : 6,
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: currentIndex == index ? const Color(0xFFD2FF1F) : Colors.white24,
            ),
          );
        }),
      ),
    );
  }
}

class _BottomActionBar extends ConsumerWidget {
  final bool canAction;
  final ProductModel product;
  final String? selectedSize;
  final String? selectedColor;

  const _BottomActionBar({required this.canAction, required this.product, this.selectedSize, this.selectedColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _ActionButton(
                label: 'GIỎ HÀNG',
                isPrimary: false,
                onPressed: !canAction ? null : () {
                  ref.read(cartProvider.notifier).addToCart(product, size: selectedSize ?? 'S', color: selectedColor ?? 'Default');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng')));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _ActionButton(
                label: 'MUA NGAY',
                isPrimary: true,
                onPressed: !canAction ? null : () => context.push('/checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback? onPressed;
  const _ActionButton({required this.label, required this.isPrimary, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFD2FF1F) : Colors.white.withOpacity(0.08),
          foregroundColor: isPrimary ? Colors.black : Colors.white,
          disabledBackgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 5,
      left: 10,
      child: IconButton(
        icon: const CircleAvatar(backgroundColor: Colors.black45, child: Icon(Icons.arrow_back, color: Colors.white, size: 20)),
        onPressed: () => context.pop(),
      ),
    );
  }
}
