import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import '../../../../data/model/AppointmentModel.dart';
import '../../../../data/model/ServiceModel.dart';
import '../../../../domain/usecase/pet/AddAppointmentUseCase.dart';
import '../../../../domain/usecase/service/GetServiceUseCase.dart';

class ServicesViewModel extends ChangeNotifier {
  final GetServicesUseCase getServicesUseCase;
  final AddAppointmentUseCase addAppointmentUseCase;
  List<ServiceModel> services = [];
  bool isLoading = false;
  String? error;

  ServicesViewModel({
    required this.getServicesUseCase,
    required this.addAppointmentUseCase,
  });

  Future<void> fetchServices() async {
    isLoading = true;
    notifyListeners();
    final result = await getServicesUseCase();
    result.fold(
      (failure) {
        error = failure;
        isLoading = false;
        notifyListeners();
      },
      (servicesList) {
        services = servicesList;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<Either<String, void>> addAppointment(
    AppointmentModel appointment,
  ) async {
    isLoading = true;
    notifyListeners();
    final result = await addAppointmentUseCase(appointment);
    isLoading = false;
    notifyListeners();
    return result;
  }
}
