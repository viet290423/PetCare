import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../provider/AuthProvider.dart';
import '../auth/AuthViewModel.dart';
import '../auth/LoginScreen.dart';
import '../../../data/model/AppointmentModel.dart';
import '../../../data/model/DoctorModel.dart';
import 'DoctorViewModel.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  void _loadAppointments() {
    // TODO: Load appointments for the current doctor
    // This will be implemented when we have the appointment data source
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
      body: Column(
        children: [
          // Header with stats
          _buildHeaderSection(),

          // Date selector
          _buildDateSelector(),

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.green,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Hôm nay'),
                Tab(text: 'Sắp tới'),
                Tab(text: 'Đã hoàn thành'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTodayAppointments(),
                _buildUpcomingAppointments(),
                _buildCompletedAppointments(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
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
          // Doctor info
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 35, color: Colors.green[700]),
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
                    const Text(
                      'Chào mừng trở lại!',
                      style: TextStyle(
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

          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Hôm nay', '5', Icons.today, Colors.blue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Chờ xác nhận',
                  '3',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Hoàn thành',
                  '12',
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

  Widget _buildTodayAppointments() {
    return _buildAppointmentsList([
      _createMockAppointment(
        id: 1,
        petName: 'Lucky',
        ownerName: 'Nguyễn Văn A',
        serviceTitle: 'Khám tổng quát',
        appointmentTime: DateTime.now().add(const Duration(hours: 1)),
        status: 'confirmed',
        petType: 'Chó',
      ),
      _createMockAppointment(
        id: 2,
        petName: 'Mimi',
        ownerName: 'Trần Thị B',
        serviceTitle: 'Tiêm vaccine',
        appointmentTime: DateTime.now().add(const Duration(hours: 2)),
        status: 'pending',
        petType: 'Mèo',
      ),
    ]);
  }

  Widget _buildUpcomingAppointments() {
    return _buildAppointmentsList([
      _createMockAppointment(
        id: 3,
        petName: 'Max',
        ownerName: 'Lê Văn C',
        serviceTitle: 'Phẫu thuật nhỏ',
        appointmentTime: DateTime.now().add(const Duration(days: 1)),
        status: 'confirmed',
        petType: 'Chó',
      ),
    ]);
  }

  Widget _buildCompletedAppointments() {
    return _buildAppointmentsList([
      _createMockAppointment(
        id: 4,
        petName: 'Bunny',
        ownerName: 'Phạm Thị D',
        serviceTitle: 'Khám định kỳ',
        appointmentTime: DateTime.now().subtract(const Duration(days: 1)),
        status: 'completed',
        petType: 'Thỏ',
      ),
    ]);
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(appointments[index]);
      },
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
            // Header with time and status
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

            // Pet and owner info
            // Row(
            //   children: [
            //     CircleAvatar(
            //       radius: 25,
            //       backgroundColor: Colors.green[100],
            //       child: Icon(
            //         _getPetIcon(appointment.petType),
            //         color: Colors.green[700],
            //         size: 25,
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             appointment.petName,
            //             style: const TextStyle(
            //               fontSize: 16,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //           Text(
            //             'Chủ: ${appointment.ownerName}',
            //             style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            //           ),
            //           Text(
            //             appointment.petType,
            //             style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),

            const SizedBox(height: 12),

            // Service info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    // _getServiceIcon(appointment.serviceTitle),
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

            // Action buttons
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

  AppointmentModel _createMockAppointment({
    required int id,
    required String petName,
    required String ownerName,
    required String serviceTitle,
    required DateTime appointmentTime,
    required String status,
    required String petType,
  }) {
    return AppointmentModel(
      id: id,
      petId: '1',
      doctorId: '1',
      serviceId: 1,
      appointmentTime: appointmentTime,
      status: status,
      notes: 'Ghi chú cho lịch hẹn',
      createdAt: DateTime.now(),
      serviceTitle: serviceTitle, userId: '1', doctorName: 'Bác sĩ A'
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

  IconData _getPetIcon(String petType) {
    switch (petType.toLowerCase()) {
      case 'chó':
        return Icons.pets;
      case 'mèo':
        return Icons.pets;
      case 'thỏ':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  IconData _getServiceIcon(String serviceTitle) {
    if (serviceTitle.contains('Khám')) return Icons.medical_services;
    if (serviceTitle.contains('Tiêm')) return Icons.vaccines;
    if (serviceTitle.contains('Phẫu thuật')) return Icons.local_hospital;
    return Icons.pets;
  }
}
