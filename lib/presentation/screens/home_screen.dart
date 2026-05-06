import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/product/product_provider.dart';
import '../../data/models/product_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optimization: Granular watching to isolate rebuilds
    final currentCategory = ref.watch(productListProvider.select((s) => s.category));

    return Column(
      children: [
        _CategoryFilter(currentCategory: currentCategory),
        const Expanded(
          child: _ProductGrid(),
        ),
      ],
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  final String currentCategory;
  const _CategoryFilter({required this.currentCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const categories = ['Tất cả', 'Giày', 'Quần', 'Áo', 'Bộ đồ', 'Phụ kiện'];
    return SizedBox(
      height: 44, // Fixed height for faster layout
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = currentCategory == cat;
          return _CategoryItem(
            label: cat,
            isSelected: isSelected,
            onTap: () => ref.read(productListProvider.notifier).setCategory(cat),
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryItem({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isSelected ? const Color(0xFFD2FF1F) : Colors.white30,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(productListProvider.select((s) => s.items));
    final isLoading = ref.watch(productListProvider.select((s) => s.isLoading));
    final hasMore = ref.watch(productListProvider.select((s) => s.hasMore));

    if (isLoading && items.isEmpty) return const _ShimmerGrid();

    return RefreshIndicator(
      color: const Color(0xFFD2FF1F),
      onRefresh: () => ref.read(productListProvider.notifier).fetchProducts(refresh: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 500) {
            ref.read(productListProvider.notifier).fetchProducts();
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length + (hasMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return isLoading ? const _LoadingCard() : const SizedBox.shrink();
            }
            // Optimization: Wrap with RepaintBoundary at grid item level
            return RepaintBoundary(
              child: _ProductCard(product: items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}', extra: product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: CachedNetworkImage(
                imageUrl: product.images.first.url,
                fit: BoxFit.cover,
                memCacheHeight: 450, // Critical for RAM/UI thread optimization
                placeholder: (context, url) => Container(color: Colors.white.withOpacity(0.05)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Optimization: Use pre-computed displayName
          Text(product.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          // Optimization: Use pre-computed displayPrice
          Text(product.displayPrice,
            style: const TextStyle(color: Color(0xFFD2FF1F), fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const _LoadingCard(),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Container(color: Colors.white),
    );
  }
}
