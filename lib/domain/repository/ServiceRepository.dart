import '../../data/model/ServiceModel.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getServices();

  Future<void> addService(ServiceModel service);
}
