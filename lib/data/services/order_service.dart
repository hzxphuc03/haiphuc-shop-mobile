import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio _dio = DioClient().dio;

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _dio.get('/orders/my');
      
      // API might return { success: true, data: [...] } or just [...]
      final List dynamicList = response.data is Map 
          ? (response.data['data'] ?? response.data['orders'] ?? []) 
          : response.data;

      return dynamicList.map((o) => OrderModel.fromJson(o)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post('/orders', data: orderData);
      return OrderModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
