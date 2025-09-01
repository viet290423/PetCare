import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/model/DoctorModel.dart';
import '../../../../data/model/ServiceModel.dart';
import '../../doctor/homeScreen/DoctorViewModel.dart';

class SelectDoctorScreen extends StatefulWidget {
  final ServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;

  const SelectDoctorScreen({
    Key? key,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
  }) : super(key: key);

  @override
  State<SelectDoctorScreen> createState() => _SelectDoctorScreenState();
}

class _SelectDoctorScreenState extends State<SelectDoctorScreen> {
  String? selectedDoctorId;
  DoctorModel? selectedDoctor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorViewModel = Provider.of<DoctorViewModel>(
        context,
        listen: false,
      );
      doctorViewModel.getDoctorsByService(widget.service.id.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chọn Bác Sĩ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        forceMaterialTransparency: true,
      ),
      body: Consumer<DoctorViewModel>(
        builder: (context, doctorViewModel, child) {
          if (doctorViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          if (doctorViewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${doctorViewModel.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      doctorViewModel.getDoctorsByService(
                        widget.service.id.toString(),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (doctorViewModel.doctors.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không có bác sĩ nào phù hợp cho dịch vụ này',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Thông tin dịch vụ và thời gian
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.green.shade900.withOpacity(0.2)
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dịch vụ: ${widget.service.title}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        // color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ngày: ${_formatDate(widget.selectedDate)}',
                      style: const TextStyle(
                        fontSize: 16,
                        // color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Giờ: ${widget.selectedTime}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Danh sách bác sĩ
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: doctorViewModel.doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctorViewModel.doctors[index];
                    final isSelected = selectedDoctorId == doctor.id;
                    final isAvailable =
                        doctor.isAvailable &&
                        doctor.isWorkingOnDay(
                          _getDayOfWeek(widget.selectedDate),
                        );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isSelected ? 4 : 2,
                      color: isSelected
                          ? (isDark
                                ? Colors.green.shade900.withOpacity(0.3)
                                : Colors.green.shade50)
                          : Theme.of(context).colorScheme.surface,
                      child: InkWell(
                        onTap: isAvailable
                            ? () {
                                setState(() {
                                  selectedDoctorId = doctor.id;
                                  selectedDoctor = doctor;
                                });
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Avatar bác sĩ
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.green.shade100,
                                child: doctor.imageUrl.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          doctor.imageUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 30,
                                                  color: Colors.green.shade600,
                                                );
                                              },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.green.shade600,
                                      ),
                              ),
                              const SizedBox(width: 16),

                              // Thông tin bác sĩ
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor.specialization,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${doctor.rating} (${doctor.reviewCount} đánh giá)',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kinh nghiệm: ${doctor.experience}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    if (!isAvailable) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'Không có lịch',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Checkbox
                              if (isAvailable)
                                Radio<String>(
                                  value: doctor.id,
                                  groupValue: selectedDoctorId,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDoctorId = value;
                                      selectedDoctor = doctor;
                                    });
                                  },
                                  activeColor: Colors.green,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Nút tiếp tục
              if (selectedDoctor != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, selectedDoctor);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Tiếp tục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return '${days[date.weekday - 1]}, ${date.day}/${date.month}/${date.year}';
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
