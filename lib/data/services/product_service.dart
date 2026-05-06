import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    try {
      final response = await _dio.get('/products', queryParameters: {
        'page': page,
        'limit': limit,
        if (category != null && category != 'Tất cả') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      });

      return {
        'items': (response.data['data'] as List).map((p) => ProductModel.fromJson(p)).toList(),
        'totalPages': response.data['totalPages'],
        'totalItems': response.data['totalItems'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return ProductModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
