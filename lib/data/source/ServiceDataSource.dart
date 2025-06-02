import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/ServiceModel.dart';

abstract class ServiceDataSource {
  Future<List<ServiceModel>> getServices();
  Future<void> addService(ServiceModel service);
}

class ServiceDataSourceImpl implements ServiceDataSource {
  final SupabaseClient client;

  ServiceDataSourceImpl(this.client);

  @override
  Future<List<ServiceModel>> getServices() async {
    try {
      final data = await client.from('services').select();
      // In dữ liệu để kiểm tra (tùy chọn)
      print(data);
      // Chuyển đổi dữ liệu thành danh sách các đối tượng (nếu cần)
      final services = data.map((json) => ServiceModel.fromJson(json)).toList();
      return services;
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu dịch vụ: $e');
    }
  }

  @override
  Future<void> addService(ServiceModel service) async {
    final data = service.toJson();
    final response = await client.from('services').insert(data);
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }
}
