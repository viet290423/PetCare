import '../model/DoctorModel.dart';
import '../model/TimeSlotModel.dart';

abstract class DoctorDataSource {
  Future<List<DoctorModel>> getAllDoctors();
  Future<List<TimeSlotModel>> getAvailableTimeSlots(
    String doctorId,
    DateTime date,
  );
}

class DoctorDataSourceImpl implements DoctorDataSource {
  @override
  Future<List<DoctorModel>> getAllDoctors() async {
    // TODO: Implement actual data fetching from Firebase/API
    // For now, return mock data
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay

    return [
      DoctorModel(
        id: '1',
        name: 'Dr. Nguyễn Văn A',
        specialization: 'Thú y tổng hợp',
        specializations: ['Thú y tổng hợp', 'Phẫu thuật', 'Tiêm chủng'],
        experience: '10 năm',
        education: 'Đại học Thú y Hà Nội',
        imageUrl: 'https://example.com/doctor1.jpg',
        description:
            'Bác sĩ thú y có kinh nghiệm 10 năm trong lĩnh vực chăm sóc thú cưng',
        certifications: ['Chứng chỉ hành nghề thú y', 'Chứng chỉ phẫu thuật'],
        rating: 4.8,
        reviewCount: 156,
        workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        workingHours: '08:00-17:00',
        isAvailable: true,
        serviceIds: ['1', '2', '3', '4'],
      ),
      DoctorModel(
        id: '2',
        name: 'Dr. Trần Thị B',
        specialization: 'Da liễu thú y',
        specializations: ['Da liễu thú y', 'Dị ứng', 'Ký sinh trùng'],
        experience: '8 năm',
        education: 'Đại học Nông Lâm TP.HCM',
        imageUrl: 'https://example.com/doctor2.jpg',
        description: 'Chuyên gia về các bệnh da liễu và dị ứng ở thú cưng',
        certifications: ['Chứng chỉ da liễu thú y', 'Chứng chỉ dị ứng học'],
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
        serviceIds: ['2', '5', '6'],
      ),
      DoctorModel(
        id: '3',
        name: 'Dr. Lê Văn C',
        specialization: 'Phẫu thuật thú y',
        specializations: ['Phẫu thuật', 'Chấn thương', 'Chỉnh hình'],
        experience: '15 năm',
        education: 'Đại học Thú y Hà Nội',
        imageUrl: 'https://example.com/doctor3.jpg',
        description: 'Bác sĩ phẫu thuật thú y có kinh nghiệm lâu năm',
        certifications: ['Chứng chỉ phẫu thuật thú y', 'Chứng chỉ chỉnh hình'],
        rating: 4.7,
        reviewCount: 89,
        workingDays: ['Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        workingHours: '10:00-19:00',
        isAvailable: true,
        serviceIds: ['3', '7', '8'],
      ),
    ];
  }

  @override
  Future<List<TimeSlotModel>> getAvailableTimeSlots(
    String doctorId,
    DateTime date,
  ) async {
    // TODO: Implement actual data fetching from Firebase/API
    // For now, return mock data
    await Future.delayed(const Duration(milliseconds: 300));

    final List<TimeSlotModel> timeSlots = [];
    final doctor = (await getAllDoctors()).firstWhere((d) => d.id == doctorId);

    if (!doctor.isWorkingOnDay(_getDayOfWeek(date))) {
      return timeSlots;
    }

    // Generate time slots based on working hours
    final workingHours = doctor.workingHours.split('-');
    final startHour = int.parse(workingHours[0].split(':')[0]);
    final endHour = int.parse(workingHours[1].split(':')[0]);

    for (int hour = startHour; hour < endHour; hour++) {
      final startTime = '${hour.toString().padLeft(2, '0')}:00';
      final endTime = '${(hour + 1).toString().padLeft(2, '0')}:00';

      // Randomly mark some slots as unavailable
      final isAvailable =
          hour != 12 && hour != 14; // Lunch break and one other slot

      timeSlots.add(
        TimeSlotModel(
          id: '${doctorId}_${date.toIso8601String().split('T')[0]}_$startTime',
          doctorId: doctorId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          isAvailable: isAvailable,
        ),
      );
    }

    return timeSlots;
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }
}
