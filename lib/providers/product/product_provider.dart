import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/product_service.dart';
import '../../data/models/product_model.dart';

final productServiceProvider = Provider((ref) => ProductService());

class ProductListState {
  final List<ProductModel> items;
  final bool isLoading;
  final int currentPage;
  final bool hasMore;
  final String category;
  final String? search;
  final String? error;

  ProductListState({
    this.items = const [],
    this.isLoading = false,
    this.currentPage = 1,
    this.hasMore = true,
    this.category = 'Tất cả',
    this.search,
    this.error,
  });

  ProductListState copyWith({
    List<ProductModel>? items,
    bool? isLoading,
    int? currentPage,
    bool? hasMore,
    String? category,
    String? search,
    String? error,
  }) {
    return ProductListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      category: category ?? this.category,
      search: search ?? this.search,
      error: error,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductService _service;
  ProductListNotifier(this._service) : super(ProductListState()) {
    fetchProducts();
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    if (state.isLoading || (!refresh && !state.hasMore)) return;

    if (refresh) {
      state = state.copyWith(items: [], currentPage: 1, hasMore: true, error: null, isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _service.getProducts(
        page: state.currentPage,
        category: state.category,
        search: state.search,
      );
      
      final List<ProductModel> newItems = result['items'];
      final totalPages = result['totalPages'] ?? 1;

      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoading: false,
        currentPage: state.currentPage + 1,
        hasMore: state.currentPage < totalPages,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: "Không thể tải sản phẩm. Vui lòng kiểm tra kết nối."
      );
    }
  }

  void setCategory(String category) {
    if (state.category == category) return;
    state = state.copyWith(category: category, search: null); // Clear search when switching category
    fetchProducts(refresh: true);
  }

  void setSearch(String? query) {
    final searchQuery = (query == null || query.isEmpty) ? null : query;
    
    // Force reset state for a clean fetch
    state = state.copyWith(
      search: searchQuery,
      category: 'Tất cả',
      currentPage: 1,
      hasMore: true,
      items: [], // Clear current items to show loading/fresh list
    );
    
    fetchProducts(refresh: true);
  }
}

final productListProvider = StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(ref.watch(productServiceProvider));
});
