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
import '../AppointmentDetailScreen.dart';
import '../DoctorScheduleScreen.dart';
import '../DoctorStatsScreen.dart';
import '../MedicalRecordsScreen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _hasFetchedAppointments = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Reset TabController về tab đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController.index != 0) {
        _tabController.animateTo(0);
      }
    });

    // Thêm listener để đồng bộ TabController với AppointmentViewModel
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final appointmentVM = Provider.of<AppointmentViewModel>(context, listen: false);
          switch (_tabController.index) {
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
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset AppointmentViewModel về 'today' khi màn hình được focus
    final appointmentVM = Provider.of<AppointmentViewModel>(context, listen: false);
    appointmentVM.setSelectedDate('today');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Trang chủ',
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

          // Hiển thị loading nếu đang kiểm tra user
          if (authViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Hiển thị thông báo nếu không có doctor info
          if (doctor == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải thông tin bác sĩ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng thử lại hoặc đăng nhập lại',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      authViewModel.refreshDoctorInfo();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Reset trạng thái nếu doctor thay đổi
          if (doctor != null && !_hasFetchedAppointments) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!appointmentVM.isLoading) {
                appointmentVM.fetchAppointmentsForDoctor(doctor.id);
                setState(() {
                  _hasFetchedAppointments = true;
                });
              }
            });
          }
          return Column(
            children: [
              _buildHeaderSection(doctor, appointmentVM),
              _buildDateSelector(),
              Container(
                color: Theme.of(context).colorScheme.surface,
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
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (doctor != null) {
                      await appointmentVM.fetchAppointmentsForDoctor(doctor.id);
                    }
                  },
                  child: Builder(
                    builder: (context) {
                      if (appointmentVM.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (appointmentVM.error != null) {
                        return Center(child: Text('Lỗi: ${appointmentVM.error}'));
                      }
                      List<AppointmentModel> filtered = appointmentVM.filteredAppointments;
                      if (_tabController.index == 2) {
                        filtered = filtered
                            .where((a) => a.status.toLowerCase() == 'completed')
                            .toList();
                      }
                      return _buildAppointmentsList(filtered);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(DoctorModel? doctor, AppointmentViewModel appointmentVM) {
    final stats = appointmentVM.appointmentStats;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade600, Colors.green.shade700],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Doctor Profile Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
            child: Row(
              children: [
                // Doctor Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: doctor?.imageUrl!.isNotEmpty == true
                        ? NetworkImage(doctor!.imageUrl!)
                        : null,
                    backgroundColor: Colors.white,
                    child: doctor?.imageUrl!.isEmpty == true
                        ? Icon(Icons.person, size: 40, color: Colors.green[700])
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bác sĩ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor?.name ?? 'Chưa cập nhật',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Trực tuyến',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Statistics Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Tổng',
                    stats['total'].toString(),
                    Icons.calendar_today,
                    Colors.blue.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Chờ xác nhận',
                    stats['pending'].toString(),
                    Icons.pending_actions,
                    Colors.orange.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Hoàn thành',
                    stats['completed'].toString(),
                    Icons.check_circle_outline,
                    Colors.green.shade300,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // // Quick Actions Section
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 20),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: _buildQuickActionButton(
          //           'Xác nhận tất cả',
          //           Icons.check_circle_outline,
          //           Colors.blue.shade400,
          //           () => _confirmAllPendingAppointments(appointmentVM),
          //         ),
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: _buildQuickActionButton(
          //           'Hoàn thành',
          //           Icons.done_all,
          //           Colors.green.shade400,
          //           () => _completeCurrentAppointments(appointmentVM),
          //         ),
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: _buildQuickActionButton(
          //           'Thêm mới',
          //           Icons.add_circle_outline,
          //           Colors.orange.shade400,
          //           () => _showAddAppointmentDialog(context),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.green[600], size: 20),
          const SizedBox(width: 10),
          Text(
            'Lịch hẹn ngày ${DateFormat('dd/MM/yyyy').format(DateTime.parse(_selectedDate))}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green[700]),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: Key(appointment.id.toString()),
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'Hoàn thành',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.cancel, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'Hủy lịch hẹn',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - Complete appointment
          return await _showConfirmDialog(
            'Hoàn thành lịch hẹn',
            'Bạn có muốn đánh dấu hoàn thành lịch hẹn này không?',
          );
        } else {
          // Swipe left - Cancel appointment
          return await _showConfirmDialog('Hủy lịch hẹn', 'Bạn có muốn hủy lịch hẹn này không?');
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // Complete appointment
          _updateAppointmentStatus(appointment, 'completed');
        } else {
          // Cancel appointment
          _updateAppointmentStatus(appointment, 'cancelled');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  color: isDark ? Theme.of(context).colorScheme.onSecondaryFixedVariant : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.serviceTitle ?? "Dịch vụ không xác định",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentDetailScreen(appointment: appointment),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Chi tiết'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmAllPendingAppointments(AppointmentViewModel appointmentVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận tất cả'),
        content: const Text('Bạn có muốn xác nhận tất cả lịch hẹn đang chờ không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement confirm all pending appointments
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Đã xác nhận tất cả lịch hẹn')));
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _completeCurrentAppointments(AppointmentViewModel appointmentVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn thành lịch hẹn'),
        content: const Text('Bạn có muốn đánh dấu hoàn thành các lịch hẹn hiện tại không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement complete current appointments
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Đã hoàn thành lịch hẹn')));
            },
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm lịch hẹn mới'),
        content: const Text('Tính năng này sẽ được phát triển trong phiên bản tiếp theo.'),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _updateAppointmentStatus(AppointmentModel appointment, String newStatus) {
    // TODO: Implement update appointment status in database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã cập nhật trạng thái lịch hẹn thành: ${_getStatusText(newStatus)}'),
        backgroundColor: _getStatusColor(newStatus),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
