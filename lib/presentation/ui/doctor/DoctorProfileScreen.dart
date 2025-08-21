import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../auth/AuthViewModel.dart';
import '../settings/SettingsScreen.dart';
import 'AppointmentViewModel.dart';
import '../auth/LoginScreen.dart';
import 'DoctorScheduleScreen.dart';
import 'MedicalRecordsScreen.dart';
import 'DoctorStatsScreen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  String _selectedPeriod = 'week'; // week, month, year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Hồ sơ bác sĩ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Consumer2<AuthViewModel, AppointmentViewModel>(
        builder: (context, authViewModel, appointmentViewModel, child) {
          final doctor = authViewModel.doctor;
          final appointments = appointmentViewModel.appointments;

          if (doctor == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final todayStats = _calculateTodayStats(appointments);
          final nextAppointment = _findNextAppointment(appointments);

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderSection(doctor),
                const SizedBox(height: 16),
                _buildSectionTitle('Tổng quan hôm nay', Icons.today),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickStat(
                        icon: Icons.calendar_today,
                        label: 'Hôm nay',
                        value: todayStats['total'].toString(),
                        color: Colors.blue,
                      ),
                      _buildQuickStat(
                        icon: Icons.check_circle,
                        label: 'Hoàn thành',
                        value: todayStats['completed'].toString(),
                        color: Colors.green,
                      ),
                      _buildQuickStat(
                        icon: Icons.pending_actions,
                        label: 'Chờ duyệt',
                        value: todayStats['pending'].toString(),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Sắp diễn ra', Icons.schedule),
                _buildNextAppointmentCard(nextAppointment),
                const SizedBox(height: 16),
                _buildSectionTitle('Hành động', Icons.grid_view),
                _buildProfileCard(
                  context,
                  icon: Icons.schedule,
                  iconBg: Colors.blue.shade100,
                  iconColor: Colors.blue,
                  title: 'Quản lý lịch làm việc',
                  subtitle: 'Xem & cập nhật lịch làm việc',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorScheduleScreen()));
                  },
                ),
                _buildProfileCard(
                  context,
                  icon: Icons.medical_services,
                  iconBg: Colors.green.shade100,
                  iconColor: Colors.green,
                  title: 'Hồ sơ y tế',
                  subtitle: 'Xem hồ sơ khám chữa bệnh',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MedicalRecordsScreen()));
                  },
                ),
                _buildProfileCard(
                  context,
                  icon: Icons.bar_chart,
                  iconBg: Colors.purple.shade100,
                  iconColor: Colors.purple,
                  title: 'Thống kê lịch hẹn',
                  subtitle: 'Theo dõi hiệu suất làm việc',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorStatsScreen()));
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                _buildSectionTitle('Sắp tới', Icons.upcoming),
                _buildRecentAppointments(appointments),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
        ),
        Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconBg,
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Map<String, int> _calculateOverviewStats(List appointments) {
    final stats = <String, int>{
      'total': appointments.length,
      'pending': 0,
      'confirmed': 0,
      'completed': 0,
      'cancelled': 0,
    };
    for (final appointment in appointments) {
      final status = (appointment.status as String?)?.toLowerCase() ?? '';
      if (stats.containsKey(status)) {
        stats[status] = (stats[status] ?? 0) + 1;
      }
    }
    return stats;
  }

  Map<String, int> _calculateTodayStats(List appointments) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final today = appointments.where((a) => a.appointmentTime.isAfter(start) && a.appointmentTime.isBefore(end)).toList();
    final stats = <String, int>{
      'total': today.length,
      'pending': 0,
      'confirmed': 0,
      'completed': 0,
      'cancelled': 0,
    };
    for (final appointment in today) {
      final status = (appointment.status as String?)?.toLowerCase() ?? '';
      if (stats.containsKey(status)) {
        stats[status] = (stats[status] ?? 0) + 1;
      }
    }
    return stats;
  }

  dynamic _findNextAppointment(List appointments) {
    final now = DateTime.now();
    final upcoming = appointments
        .where((a) => (a.status == 'pending' || a.status == 'confirmed') && a.appointmentTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  Widget _buildNextAppointmentCard(dynamic appointment) {
    if (appointment == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.event_busy, color: Colors.grey[500]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Chưa có lịch hẹn sắp diễn ra',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorScheduleScreen()));
                },
                child: const Text('Xem lịch'),
              )
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(appointment.status),
                    style: TextStyle(color: _getStatusColor(appointment.status), fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('HH:mm, dd/MM').format(appointment.appointmentTime),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.serviceTitle ?? 'Dịch vụ không xác định',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: navigate to detail screen if exists
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Chi tiết'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: start appointment flow
                  },
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Bắt đầu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(doctor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: doctor.imageUrl.isNotEmpty
                ? NetworkImage(doctor.imageUrl)
                : null,
            backgroundColor: Colors.white,
            child: doctor.imageUrl.isEmpty
                ? Icon(Icons.person, size: 50, color: Colors.green[700])
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            doctor.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            doctor.specialization,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Thời gian:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          _buildPeriodChip('Tuần', 'week'),
          const SizedBox(width: 8),
          _buildPeriodChip('Tháng', 'month'),
          const SizedBox(width: 8),
          _buildPeriodChip('Năm', 'year'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng lịch hẹn',
                  stats['total'].toString(),
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Đã hoàn thành',
                  stats['completed'].toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Chờ xác nhận',
                  stats['pending'].toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Đã hủy',
                  stats['cancelled'].toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAppointments(List appointments) {
    final recentAppointments = appointments
        .where(
          (appointment) =>
              appointment.status == 'pending' ||
              appointment.status == 'confirmed',
        )
        .take(5)
        .toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Lịch hẹn sắp tới',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentAppointments.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Không có lịch hẹn sắp tới',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentAppointments.length,
              itemBuilder: (context, index) {
                final appointment = recentAppointments[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        appointment.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      color: _getStatusColor(appointment.status),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    appointment.serviceTitle ?? 'Dịch vụ không xác định',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat(
                      'HH:mm, dd/MM',
                    ).format(appointment.appointmentTime),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        appointment.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(appointment.status),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getStatusColor(appointment.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(List appointments) {
    final statusCounts = <String, int>{};
    for (final appointment in appointments) {
      statusCounts[appointment.status] =
          (statusCounts[appointment.status] ?? 0) + 1;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Phân bố trạng thái',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...statusCounts.entries.map((entry) {
            final percentage = appointments.isEmpty
                ? 0.0
                : (entry.value / appointments.length * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(entry.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(entry.key),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStatusColor(entry.key),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List appointments) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    final filteredAppointments = appointments.where((appointment) {
      return appointment.appointmentTime.isAfter(startDate);
    }).toList();

    final stats = <String, int>{
      'total': filteredAppointments.length,
      'pending': 0,
      'confirmed': 0,
      'completed': 0,
      'cancelled': 0,
    };

    for (final appointment in filteredAppointments) {
      final status = appointment.status.toLowerCase();
      if (stats.containsKey(status)) {
        stats[status] = (stats[status] ?? 0) + 1;
      }
    }

    return stats;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}


