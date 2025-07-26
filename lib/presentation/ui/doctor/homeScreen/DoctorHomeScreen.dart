import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../provider/AuthProvider.dart';
import '../../auth/AuthViewModel.dart';
import '../../auth/LoginScreen.dart';
import '../../../../data/model/AppointmentModel.dart';
import '../../../../data/model/DoctorModel.dart';
import 'DoctorViewModel.dart';
import '../AppointmentViewModel.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _hasFetchedAppointments = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final doctor = Provider.of<AuthViewModel>(context, listen: false).doctor;
    //   print('Doctor in initState: $doctor');
    //   print('Doctor ID in initState: ${doctor?.id}');
    //   if (doctor != null) {
    //     Provider.of<AppointmentViewModel>(
    //       context,
    //       listen: false,
    //     ).fetchAppointmentsForDoctor(doctor.id);
    //   }
    //   print('Fetching appointments for doctor ID: ${doctor?.id}');
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Trang chủ - Bác sĩ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final authViewModel = context.read<AuthViewModel>();
              await authViewModel.signOutUser();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Consumer2<AuthViewModel, AppointmentViewModel>(
        builder: (context, authViewModel, appointmentVM, child) {
          final doctor = authViewModel.doctor;
          print('Consumer doctor: $doctor');
          print('Consumer doctor ID: ${doctor?.id}');

          // Gọi fetchAppointmentsForDoctor chỉ khi chưa tải và doctor có giá trị
          if (doctor != null &&
              !_hasFetchedAppointments &&
              appointmentVM.appointments.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!appointmentVM.isLoading) {
                appointmentVM.fetchAppointmentsForDoctor(doctor.id);
                setState(() {
                  _hasFetchedAppointments = true; // Đánh dấu đã gọi
                });
              }
            });
          }
          return Column(
            children: [
              _buildHeaderSection(doctor, appointmentVM),
              _buildDateSelector(),
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Colors.green,
                  indicatorWeight: 3,
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        appointmentVM.setSelectedDate('today');
                        break;
                      case 1:
                        appointmentVM.setSelectedDate('week');
                        break;
                      case 2:
                        appointmentVM.setSelectedDate('all');
                        break;
                    }
                  },
                  tabs: const [
                    Tab(text: 'Hôm nay'),
                    Tab(text: 'Sắp tới'),
                    Tab(text: 'Đã hoàn thành'),
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (appointmentVM.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (appointmentVM.error != null) {
                      return Center(child: Text('Lỗi: ${appointmentVM.error}'));
                    }
                    List<AppointmentModel> filtered =
                        appointmentVM.filteredAppointments;
                    if (_tabController.index == 2) {
                      filtered = filtered
                          .where((a) => a.status.toLowerCase() == 'completed')
                          .toList();
                    }
                    return _buildAppointmentsList(filtered);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(
    DoctorModel? doctor,
    AppointmentViewModel appointmentVM,
  ) {
    final stats = appointmentVM.appointmentStats;
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
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: doctor?.imageUrl.isNotEmpty == true
                    ? NetworkImage(doctor!.imageUrl)
                    : null,
                backgroundColor: Colors.white,
                child: doctor?.imageUrl.isEmpty == true
                    ? Icon(Icons.person, size: 35, color: Colors.green[700])
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bác sĩ',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      doctor?.name ?? 'Chưa cập nhật',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Trực tuyến',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng',
                  stats['total'].toString(),
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Chờ xác nhận',
                  stats['pending'].toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Hoàn thành',
                  stats['completed'].toString(),
                  Icons.check_circle,
                  Colors.green,
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.green[600], size: 20),
          const SizedBox(width: 10),
          Text(
            'Lịch hẹn ngày ${DateFormat('dd/MM/yyyy').format(DateTime.parse(_selectedDate))}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.green[600]),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    print("Appointments : $appointments");
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: appointments.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Không có lịch hẹn nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tất cả lịch hẹn sẽ hiển thị ở đây',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  return _buildAppointmentCard(appointments[index]);
                },
              ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(appointment.status),
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('HH:mm').format(appointment.appointmentTime),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.serviceTitle ?? "Dịch vụ không xác định",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: View details
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Chi tiết'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Start appointment
                    },
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Bắt đầu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
