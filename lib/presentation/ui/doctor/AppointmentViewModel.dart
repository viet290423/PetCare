import 'package:flutter/foundation.dart';
import '../../../data/model/AppointmentModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentViewModel extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;
  String _selectedDate = 'today'; // today, tomorrow, week
  String _selectedStatus = 'all'; // all, pending, confirmed, completed, cancelled
  late final RealtimeChannel _channel;

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
        return appointment.status.toLowerCase() == _selectedStatus.toLowerCase();
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
    if (doctorId == null) {
      _error = 'Doctor ID is null';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("Attempting to fetch appointments for doctor: $doctorId");
      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, services(title)')
          .eq('doctor_id', doctorId);
      print('Supabase response: $response');
      _appointments = (response as List)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
      print('Appointments after mapping: $_appointments');
      _subscribeToAppointments(doctorId); // Subscribe after initial fetch
    } catch (e) {
      _error = 'Không thể tải danh sách lịch hẹn: $e';
      print('Error fetching appointments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToAppointments(String doctorId) {
    _channel = Supabase.instance.client
        .channel('appointments-$doctorId')
        .onPostgresChanges(
      event: PostgresChangeEvent.all, // Lắng nghe tất cả sự kiện (INSERT, UPDATE, DELETE)
      schema: 'public',
      table: 'appointments',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'doctor_id=eq.$doctorId',
        value: 200,
      ),
      callback: (payload) {
        print('Realtime payload: $payload');
        if (payload.eventType == 'INSERT' ||
            payload.eventType == 'UPDATE' ||
            payload.eventType == 'DELETE') {
          _handleRealtimeUpdate(doctorId, payload);
        }
      },
    )
        .subscribe(
          (status, [error]) {
        if (status == 'SUBSCRIBED') {
          print('Subscribed to appointments channel for doctor: $doctorId');
        } else if (error != null) {
          print('Subscription error: $error');
        }
      },
    );
  }
  void _handleRealtimeUpdate(String doctorId, PostgresChangePayload payload) {
    final newData = payload.newRecord as Map<String, dynamic>?;
    final oldData = payload.oldRecord as Map<String, dynamic>?;
    final appointmentId = newData?['id'] ?? oldData?['id'];

    if (newData != null && newData['doctor_id'] == doctorId) {
      final updatedAppointment = AppointmentModel.fromJson(newData);
      final index = _appointments.indexWhere((app) => app.id == appointmentId);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
      } else {
        _appointments.add(updatedAppointment);
      }
    } else if (oldData != null && oldData['doctor_id'] == doctorId) {
      _appointments.removeWhere((app) => app.id == appointmentId);
    }

    notifyListeners();
  }

  Future<void> updateAppointmentStatus(int appointmentId, String newStatus) async {
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

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }
}