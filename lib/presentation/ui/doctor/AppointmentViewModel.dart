import 'package:flutter/foundation.dart';
import '../../../data/model/AppointmentModel.dart';

class AppointmentViewModel extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;
  String _selectedDate = 'today'; // today, tomorrow, week
  String _selectedStatus =
      'all'; // all, pending, confirmed, completed, cancelled

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedDate => _selectedDate;
  String get selectedStatus => _selectedStatus;

  // Lọc lịch hẹn theo ngày và trạng thái
  List<AppointmentModel> get filteredAppointments {
    List<AppointmentModel> filtered = _appointments;
    final now = DateTime.now();

    switch (_selectedDate) {
      case 'today':
        filtered = filtered.where((appointment) {
          final appointmentDate = DateTime(
            appointment.appointmentTime.year,
            appointment.appointmentTime.month,
            appointment.appointmentTime.day,
          );
          final today = DateTime(now.year, now.month, now.day);
          return appointmentDate.isAtSameMomentAs(today);
        }).toList();
        break;
      case 'tomorrow':
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        filtered = filtered.where((appointment) {
          final appointmentDate = DateTime(
            appointment.appointmentTime.year,
            appointment.appointmentTime.month,
            appointment.appointmentTime.day,
          );
          return appointmentDate.isAtSameMomentAs(tomorrow);
        }).toList();
        break;
      case 'week':
        final weekFromNow = now.add(const Duration(days: 7));
        filtered = filtered.where((appointment) {
          return appointment.appointmentTime.isAfter(now) &&
              appointment.appointmentTime.isBefore(weekFromNow);
        }).toList();
        break;
    }

    if (_selectedStatus != 'all') {
      filtered = filtered.where((appointment) {
        return appointment.status.toLowerCase() ==
            _selectedStatus.toLowerCase();
      }).toList();
    }

    filtered.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
    return filtered;
  }

  // Thống kê
  Map<String, int> get appointmentStats {
    final stats = <String, int>{
      'total': _appointments.length,
      'pending': 0,
      'confirmed': 0,
      'completed': 0,
      'cancelled': 0,
    };

    for (final appointment in _appointments) {
      final status = appointment.status.toLowerCase();
      if (stats.containsKey(status)) {
        stats[status] = (stats[status] ?? 0) + 1;
      }
    }

    return stats;
  }

  void setSelectedDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> fetchAppointmentsForDoctor(String doctorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _appointments = _getMockAppointments(doctorId);
    } catch (e) {
      _error = 'Không thể tải danh sách lịch hẹn: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointmentStatus(
    int appointmentId,
    String newStatus,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _appointments.indexWhere((app) => app.id == appointmentId);
      if (index != -1) {
        _appointments[index] = AppointmentModel(
          id: _appointments[index].id,
          serviceId: _appointments[index].serviceId,
          serviceTitle: _appointments[index].serviceTitle,
          petId: _appointments[index].petId,
          userId: _appointments[index].userId,
          doctorId: _appointments[index].doctorId,
          doctorName: _appointments[index].doctorName,
          appointmentTime: _appointments[index].appointmentTime,
          status: newStatus,
          createdAt: _appointments[index].createdAt,
          notes: _appointments[index].notes,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Không thể cập nhật trạng thái lịch hẹn: $e';
      notifyListeners();
    }
  }

  // Mock data for testing
  List<AppointmentModel> _getMockAppointments(String doctorId) {
    final now = DateTime.now();
    return [
      AppointmentModel(
        id: 1,
        serviceId: 1,
        serviceTitle: 'Khám tổng quát',
        petId: 'pet1',
        userId: 'user1',
        doctorId: doctorId,
        doctorName: 'Dr. Nguyễn Văn A',
        appointmentTime: DateTime(now.year, now.month, now.day, 9, 0),
        status: 'confirmed',
        createdAt: now.subtract(const Duration(hours: 2)),
        notes: 'Chó Golden, 2 tuổi, cần khám định kỳ',
      ),
      AppointmentModel(
        id: 2,
        serviceId: 2,
        serviceTitle: 'Tiêm vaccine',
        petId: 'pet2',
        userId: 'user2',
        doctorId: doctorId,
        doctorName: 'Dr. Nguyễn Văn A',
        appointmentTime: DateTime(now.year, now.month, now.day, 10, 30),
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 1)),
        notes: 'Mèo Anh lông ngắn, 6 tháng tuổi',
      ),
      AppointmentModel(
        id: 3,
        serviceId: 3,
        serviceTitle: 'Phẫu thuật nhỏ',
        petId: 'pet3',
        userId: 'user3',
        doctorId: doctorId,
        doctorName: 'Dr. Nguyễn Văn A',
        appointmentTime: DateTime(now.year, now.month, now.day + 1, 14, 0),
        status: 'confirmed',
        createdAt: now.subtract(const Duration(days: 1)),
        notes: 'Chó Poodle, cần cắt móng',
      ),
      AppointmentModel(
        id: 4,
        serviceId: 1,
        serviceTitle: 'Khám tổng quát',
        petId: 'pet4',
        userId: 'user4',
        doctorId: doctorId,
        doctorName: 'Dr. Nguyễn Văn A',
        appointmentTime: DateTime(now.year, now.month, now.day - 1, 15, 0),
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 2)),
        notes: 'Mèo Ba Tư, khám định kỳ',
      ),
      AppointmentModel(
        id: 5,
        serviceId: 2,
        serviceTitle: 'Tiêm vaccine',
        petId: 'pet5',
        userId: 'user5',
        doctorId: doctorId,
        doctorName: 'Dr. Nguyễn Văn A',
        appointmentTime: DateTime(now.year, now.month, now.day + 2, 11, 0),
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 3)),
        notes: 'Chó Husky, 1 tuổi',
      ),
    ];
  }
}
