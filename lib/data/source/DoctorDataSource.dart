import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/DoctorModel.dart';
import '../model/TimeSlotModel.dart';

abstract class DoctorDataSource {
  Future<List<DoctorModel>> getAllDoctors();
  Future<DoctorModel?> getDoctorByUserId(String userId);
  Future<List<TimeSlotModel>> getAvailableTimeSlots(
    String doctorId,
    DateTime date,
  );
}

class DoctorDataSourceImpl implements DoctorDataSource {
  final SupabaseClient client;
  DoctorDataSourceImpl(this.client);
  @override
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final response = await client
          .from('doctors')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy tất cả bác sĩ: $e');
    }
  }

  @override
  Future<DoctorModel?> getDoctorByUserId(String userId) async {
    try {
      final response = await client
          .from('doctors')
          .select()
          .eq('user_id', userId)
          .single();
      return DoctorModel.fromJson(response);
    } catch (e) {
      return null; // Trả về null nếu không tìm thấy
    }
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
