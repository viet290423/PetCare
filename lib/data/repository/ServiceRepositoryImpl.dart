import '../../domain/repository/ServiceRepository.dart';
import '../model/ServiceModel.dart';
import '../source/ServiceDataSource.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceDataSource serviceDataSource;

  ServiceRepositoryImpl(this.serviceDataSource);

  @override
  Future<List<ServiceModel>> getServices() {
    return serviceDataSource.getServices();
  }

  @override
  Future<void> addService(ServiceModel service) {
    return serviceDataSource.addService(service);
  }
}
