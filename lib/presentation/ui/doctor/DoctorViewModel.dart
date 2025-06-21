import 'package:flutter/foundation.dart';
import '../../../data/model/DoctorModel.dart';

class DoctorViewModel extends ChangeNotifier {
  List<DoctorModel> _doctors = [];
  bool _isLoading = false;
  String? _error;

  List<DoctorModel> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDoctors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      _doctors = [
        DoctorModel(
          id: '1',
          name: 'Dr. Nguyễn Văn An',
          specialization: 'Bác sĩ thú y tổng hợp',
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
        ),
        DoctorModel(
          id: '2',
          name: 'Dr. Trần Thị Bình',
          specialization: 'Bác sĩ chuyên khoa phẫu thuật',
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
        ),
        DoctorModel(
          id: '3',
          name: 'Dr. Lê Văn Cường',
          specialization: 'Bác sĩ chuyên khoa da liễu',
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
        ),
        DoctorModel(
          id: '4',
          name: 'Dr. Phạm Thị Dung',
          specialization: 'Bác sĩ chuyên khoa tim mạch',
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
        ),
      ];
    } catch (e) {
      _error = 'Không thể tải danh sách bác sĩ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<DoctorModel> getDoctorsBySpecialization(String specialization) {
    return _doctors
        .where(
          (doctor) => doctor.specialization.toLowerCase().contains(
            specialization.toLowerCase(),
          ),
        )
        .toList();
  }

  List<DoctorModel> searchDoctors(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _doctors
        .where(
          (doctor) =>
              doctor.name.toLowerCase().contains(lowercaseQuery) ||
              doctor.specialization.toLowerCase().contains(lowercaseQuery) ||
              doctor.description.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }
}
