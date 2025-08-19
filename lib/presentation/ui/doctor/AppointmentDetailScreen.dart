import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/model/AppointmentModel.dart';
import '../../../data/model/PetModel.dart';
import '../../../data/model/ServiceModel.dart';
import '../../../data/model/DoctorModel.dart';
import '../auth/AuthViewModel.dart';
import 'AppointmentViewModel.dart';
import 'AddMedicalRecordByDoctorScreen.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  PetModel? petInfo;
  ServiceModel? serviceInfo;
  bool isLoadingPet = false;
  bool isLoadingService = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
    _loadPetInfo();
    _loadServiceInfo();
  }

  Future<void> _loadPetInfo() async {
    setState(() {
      isLoadingPet = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('pets')
          .select()
          .eq('id', widget.appointment.petId)
          .single();

      setState(() {
        petInfo = PetModel.fromJson(response);
        isLoadingPet = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPet = false;
      });
    }
  }

  Future<void> _loadServiceInfo() async {
    setState(() {
      isLoadingService = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('services')
          .select()
          .eq('id', widget.appointment.serviceId)
          .single();

      setState(() {
        serviceInfo = ServiceModel.fromJson(response);
        isLoadingService = false;
      });
    } catch (e) {
      setState(() {
        isLoadingService = false;
      });
    }
  }

  Future<void> _updateAppointmentStatus(String newStatus) async {
    final appointmentId = widget.appointment.id;
    if (appointmentId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: ID lịch hẹn không tồn tại'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      print('Updating appointment ID: $appointmentId to status: $newStatus'); // Thêm log để debug
      final response = await Supabase.instance.client
          .from('appointments')
          .update({'status': newStatus})
          .eq('id', appointmentId)
          .select();  // Add select() để lấy updated rows

      print('Update response: $response');  // Log response để check (nên thấy list với 1 row nếu success)

      if (response.isEmpty) {
        throw Exception('No rows updated. Kiểm tra RLS policy hoặc ID không match.');
      }

      // Refresh appointment data
      final appointmentViewModel = context.read<AppointmentViewModel>();
      final doctor = context.read<AuthViewModel>().doctor;
      if (doctor != null) {
        await appointmentViewModel.fetchAppointmentsForDoctor(doctor.id); // Await để đảm bảo fetch xong
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã cập nhật trạng thái thành: ${_getStatusText(newStatus)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating status: $e'); // Thêm log lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Chi tiết lịch hẹn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header với thông tin cơ bản
            _buildHeaderSection(),

            // Thông tin thú cưng
            _buildPetInfoSection(),

            // Thông tin dịch vụ
            _buildServiceInfoSection(),

            // Thông tin lịch hẹn
            _buildAppointmentInfoSection(),

            // Ghi chú
            if (widget.appointment.notes != null &&
                widget.appointment.notes!.isNotEmpty)
              _buildNotesSection(),

            // Actions
            _buildActionButtons(),

            const SizedBox(height: 20),
          ],
        ),
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
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.appointment.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(widget.appointment.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Appointment time
          Text(
            DateFormat(
              'EEEE, dd/MM/yyyy',
              'vi_VN',
            ).format(widget.appointment.appointmentTime),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            DateFormat('HH:mm').format(widget.appointment.appointmentTime),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pets, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Thông tin thú cưng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (isLoadingPet)
            const Center(child: CircularProgressIndicator())
          else if (petInfo != null)
            Row(
              children: [
                // Pet image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade200, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      petInfo!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.pets,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Pet details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        petInfo!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${petInfo!.breed} • ${petInfo!.gender}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Tuổi: ${_calculateAge(petInfo!.birthDate)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Cân nặng: ${petInfo!.weight}kg',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            const Text('Không thể tải thông tin thú cưng'),
        ],
      ),
    );
  }

  Widget _buildServiceInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Dịch vụ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (isLoadingService)
            const Center(child: CircularProgressIndicator())
          else if (serviceInfo != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceInfo!.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                if (serviceInfo!.description != null) ...[
                  Text(
                    serviceInfo!.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),
                ],

                if (serviceInfo!.price != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      'Giá: ${NumberFormat('#,###', 'vi_VN').format(serviceInfo!.price)} VNĐ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
              ],
            )
          else
            Text(
              widget.appointment.serviceTitle ?? 'Dịch vụ không xác định',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Thông tin lịch hẹn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildInfoRow('Mã lịch hẹn', '#${widget.appointment.id}'),
          _buildInfoRow(
            'Ngày tạo',
            widget.appointment.createdAt != null
                ? DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(widget.appointment.createdAt!)
                : 'Không có thông tin',
          ),
          _buildInfoRow(
            'Thời gian',
            DateFormat(
              'HH:mm, dd/MM/yyyy',
            ).format(widget.appointment.appointmentTime),
          ),
          _buildInfoRow(
            'Trạng thái',
            _getStatusText(widget.appointment.status),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Ghi chú',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              widget.appointment.notes!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Chỉ hiển thị action buttons nếu status là pending hoặc confirmed
          if (widget.appointment.status == 'pending') ...[
            ElevatedButton.icon(
              onPressed: () => _showConfirmDialog('confirmed'),
              icon: const Icon(Icons.check_circle),
              label: const Text('Xác nhận lịch hẹn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _showConfirmDialog('cancelled'),
              icon: const Icon(Icons.cancel),
              label: const Text('Từ chối lịch hẹn'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],

          if (widget.appointment.status == 'confirmed') ...[
            ElevatedButton.icon(
              onPressed: () => _showConfirmDialog('completed'),
              icon: const Icon(Icons.done_all),
              label: const Text('Hoàn thành khám'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                if (petInfo == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không có thông tin thú cưng để ghi hồ sơ'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMedicalRecordByDoctorScreen(
                      appointment: widget.appointment,
                      pet: petInfo!,
                    ),
                  ),
                );
                if (result == true) {
                  final doctor = context.read<AuthViewModel>().doctor;
                  if (doctor != null) {
                    await context
                        .read<AppointmentViewModel>()
                        .fetchAppointmentsForDoctor(doctor.id);
                  }
                }
              },
              icon: const Icon(Icons.medical_information),
              label: const Text('Ghi hồ sơ bệnh án'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(String birthDate) {
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      final difference = now.difference(birth);
      final years = difference.inDays ~/ 365;
      final months = (difference.inDays % 365) ~/ 30;

      if (years > 0) {
        return '$years tuổi${months > 0 ? ' $months tháng' : ''}';
      } else {
        return '$months tháng';
      }
    } catch (e) {
      return 'Không xác định';
    }
  }

  void _showConfirmDialog(String newStatus) {
    String title = '';
    String message = '';

    switch (newStatus) {
      case 'confirmed':
        title = 'Xác nhận lịch hẹn';
        message = 'Bạn có chắc chắn muốn xác nhận lịch hẹn này?';
        break;
      case 'completed':
        title = 'Hoàn thành khám';
        message = 'Bạn có chắc chắn muốn đánh dấu lịch hẹn này đã hoàn thành?';
        break;
      case 'cancelled':
        title = 'Từ chối lịch hẹn';
        message = 'Bạn có chắc chắn muốn từ chối lịch hẹn này?';
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateAppointmentStatus(newStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(newStatus),
                foregroundColor: Colors.white,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}
