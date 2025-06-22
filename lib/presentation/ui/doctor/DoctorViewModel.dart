import 'package:flutter/foundation.dart';
import '../../../data/model/DoctorModel.dart';
import '../../../data/model/TimeSlotModel.dart';
import '../../../domain/usecase/doctor/GetDoctorsByServiceUseCase.dart';
import '../../../domain/usecase/doctor/GetAvailableTimeSlotsUseCase.dart';

class DoctorViewModel extends ChangeNotifier {
  final GetDoctorsByServiceUseCase _getDoctorsByServiceUseCase;
  final GetAvailableTimeSlotsUseCase _getAvailableTimeSlotsUseCase;

  List<DoctorModel> _doctors = [];
  List<TimeSlotModel> _availableTimeSlots = [];
  bool _isLoading = false;
  String? _error;

  List<DoctorModel> get doctors => _doctors;
  List<TimeSlotModel> get availableTimeSlots => _availableTimeSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DoctorViewModel({
    required GetDoctorsByServiceUseCase getDoctorsByServiceUseCase,
    required GetAvailableTimeSlotsUseCase getAvailableTimeSlotsUseCase,
  }) : _getDoctorsByServiceUseCase = getDoctorsByServiceUseCase,
       _getAvailableTimeSlotsUseCase = getAvailableTimeSlotsUseCase;

  Future<void> fetchDoctors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual data fetching
      // For now, use mock data
      await Future.delayed(const Duration(seconds: 1));

      _doctors = [
        DoctorModel(
          id: '1',
          name: 'Dr. Nguyễn Văn An',
          specialization: 'Bác sĩ thú y tổng hợp',
          specializations: ['Thú y tổng hợp', 'Phẫu thuật', 'Tiêm chủng'],
          experience: '15 năm kinh nghiệm',
          education: 'Đại học Nông Lâm TP.HCM - Khoa Thú y',
          imageUrl: 'https://example.com/doctor1.jpg',
          description:
              'Chuyên gia về chẩn đoán và điều trị các bệnh thường gặp ở chó mèo. Có kinh nghiệm sâu rộng trong phẫu thuật và chăm sóc thú cưng.',
          certifications: [
            'Chứng chỉ hành nghề thú y',
            'Chứng chỉ phẫu thuật thú cưng',
            'Chứng chỉ dinh dưỡng thú y',
          ],
          rating: 4.8,
          reviewCount: 156,
          workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
          workingHours: '08:00-17:00',
          isAvailable: true,
          serviceIds: ['1', '2', '3', '4'],
        ),
        DoctorModel(
          id: '2',
          name: 'Dr. Trần Thị Bình',
          specialization: 'Bác sĩ chuyên khoa phẫu thuật',
          specializations: ['Phẫu thuật', 'Chấn thương', 'Chỉnh hình'],
          experience: '12 năm kinh nghiệm',
          education: 'Đại học Y Dược TP.HCM - Chuyên khoa Thú y',
          imageUrl: 'https://example.com/doctor2.jpg',
          description:
              'Chuyên gia phẫu thuật thú cưng với nhiều ca phẫu thuật phức tạp thành công. Đặc biệt giỏi trong các ca phẫu thuật chỉnh hình.',
          certifications: [
            'Chứng chỉ phẫu thuật thú cưng nâng cao',
            'Chứng chỉ gây mê hồi sức',
            'Chứng chỉ chỉnh hình thú y',
          ],
          rating: 4.9,
          reviewCount: 203,
          workingDays: [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
          ],
          workingHours: '09:00-18:00',
          isAvailable: true,
          serviceIds: ['3', '7', '8'],
        ),
        DoctorModel(
          id: '3',
          name: 'Dr. Lê Văn Cường',
          specialization: 'Bác sĩ chuyên khoa da liễu',
          specializations: ['Da liễu thú y', 'Dị ứng', 'Ký sinh trùng'],
          experience: '10 năm kinh nghiệm',
          education: 'Đại học Nông Lâm Hà Nội - Khoa Thú y',
          imageUrl: 'https://example.com/doctor3.jpg',
          description:
              'Chuyên gia về các bệnh da liễu và dị ứng ở thú cưng. Có nhiều năm nghiên cứu về các bệnh da phức tạp.',
          certifications: [
            'Chứng chỉ da liễu thú y',
            'Chứng chỉ dị ứng học',
            'Chứng chỉ miễn dịch học',
          ],
          rating: 4.7,
          reviewCount: 98,
          workingDays: ['Tuesday', 'Wednesday', 'Thursday', 'Friday'],
          workingHours: '10:00-19:00',
          isAvailable: true,
          serviceIds: ['2', '5', '6'],
        ),
        DoctorModel(
          id: '4',
          name: 'Dr. Phạm Thị Dung',
          specialization: 'Bác sĩ chuyên khoa tim mạch',
          specializations: ['Tim mạch', 'Siêu âm', 'Điện tâm đồ'],
          experience: '8 năm kinh nghiệm',
          education: 'Đại học Y Dược Hà Nội - Chuyên khoa Thú y',
          imageUrl: 'https://example.com/doctor4.jpg',
          description:
              'Chuyên gia về các bệnh tim mạch ở thú cưng. Có kinh nghiệm trong chẩn đoán và điều trị các bệnh tim bẩm sinh và mắc phải.',
          certifications: [
            'Chứng chỉ tim mạch thú y',
            'Chứng chỉ siêu âm tim',
            'Chứng chỉ điện tâm đồ',
          ],
          rating: 4.6,
          reviewCount: 87,
          workingDays: ['Monday', 'Wednesday', 'Friday'],
          workingHours: '08:00-16:00',
          isAvailable: true,
          serviceIds: ['9', '10'],
        ),
      ];
    } catch (e) {
      _error = 'Không thể tải danh sách bác sĩ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getDoctorsByService(String serviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doctors = await _getDoctorsByServiceUseCase.execute(serviceId);
    } catch (e) {
      _error = 'Không thể tải danh sách bác sĩ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAvailableTimeSlots(String doctorId, DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableTimeSlots = await _getAvailableTimeSlotsUseCase.execute(
        doctorId,
        date,
      );
    } catch (e) {
      _error = 'Không thể tải lịch làm việc: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<DoctorModel> getDoctorsBySpecialization(String specialization) {
    return _doctors
        .where((doctor) => doctor.specializations.contains(specialization))
        .toList();
  }

  List<DoctorModel> searchDoctors(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _doctors
        .where(
          (doctor) =>
              doctor.name.toLowerCase().contains(lowercaseQuery) ||
              doctor.specialization.toLowerCase().contains(lowercaseQuery) ||
              doctor.specializations.any(
                (spec) => spec.toLowerCase().contains(lowercaseQuery),
              ) ||
              doctor.description.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Lọc bác sĩ có sẵn
  List<DoctorModel> getAvailableDoctors() {
    return _doctors.where((doctor) => doctor.isAvailable).toList();
  }

  // Lọc bác sĩ theo ngày làm việc
  List<DoctorModel> getDoctorsByWorkingDay(String dayOfWeek) {
    return _doctors
        .where((doctor) => doctor.isWorkingOnDay(dayOfWeek))
        .toList();
  }
}
