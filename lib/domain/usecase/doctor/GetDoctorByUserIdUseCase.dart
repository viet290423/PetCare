import 'package:petcare/data/model/DoctorModel.dart';

import '../../repository/DoctorRepository.dart';

class GetDoctorByUserIdUseCase {
  final DoctorRepository _doctorRepository;

  GetDoctorByUserIdUseCase(this._doctorRepository);

  Future<DoctorModel?> execute({required String userId}) async {
    return await _doctorRepository.getDoctorByUserId(userId);
  }
}