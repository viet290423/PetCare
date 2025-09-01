import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../data/model/MedicalRecordModel.dart';
import '../../../data/model/AppointmentModel.dart';
import '../../../data/model/PetModel.dart';
import 'AppointmentViewModel.dart';
import '../../../domain/usecase/pet/AddMedicalRecordUseCase.dart';

class AddMedicalRecordByDoctorScreen extends StatefulWidget {
  final AppointmentModel appointment;
  final PetModel pet;

  const AddMedicalRecordByDoctorScreen({
    super.key,
    required this.appointment,
    required this.pet,
  });

  @override
  State<AddMedicalRecordByDoctorScreen> createState() =>
      _AddMedicalRecordByDoctorScreenState();
}

class _AddMedicalRecordByDoctorScreenState
    extends State<AddMedicalRecordByDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _costController = TextEditingController();

  String _selectedRecordType = 'checkup';
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextVisitDate;

  final List<String> _recordTypes = [
    'checkup',
    'vaccination',
    'treatment',
    'surgery',
    'test',
  ];

  @override
  void initState() {
    super.initState();
    // Tự động điền thông tin từ appointment
    _titleController.text = widget.appointment.serviceTitle ?? 'Khám thú cưng';
    _selectedDate = widget.appointment.appointmentTime;

    // Tự động tính ngày tái khám dựa trên loại dịch vụ
    if (widget.appointment.serviceTitle?.toLowerCase().contains('tiêm') ==
        true) {
      _selectedRecordType = 'vaccination';
      _nextVisitDate = DateTime(
        _selectedDate.year + 1,
        _selectedDate.month,
        _selectedDate.day,
      );
    } else if (widget.appointment.serviceTitle?.toLowerCase().contains(
          'khám',
        ) ==
        true) {
      _selectedRecordType = 'checkup';
      _nextVisitDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + 6,
        _selectedDate.day,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isNextVisit) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isNextVisit
          ? _nextVisitDate ?? DateTime.now()
          : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isNextVisit) {
          _nextVisitDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final appointmentViewModel = Provider.of<AppointmentViewModel>(
        context,
        listen: false,
      );

      final record = MedicalRecordModel(
        id: const Uuid().v4(),
        petId: widget.pet.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        recordType: _selectedRecordType,
        recordDate: _selectedDate,
        doctorId: widget.appointment.doctorId,
        doctorName: widget.appointment.doctorName,
        status: 'completed',
        cost: _costController.text.isNotEmpty
            ? double.tryParse(_costController.text)
            : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        nextVisitDate: _nextVisitDate?.toIso8601String().split('T')[0],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Lưu hồ sơ y tế thông qua use case đã đăng ký trong DI
      final addMedicalRecordUseCase = GetIt.I<AddMedicalRecordUseCase>();
      final result = await addMedicalRecordUseCase(record);
      result.fold((error) => throw Exception(error), (_) => null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm hồ sơ y tế thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm hồ sơ y tế',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appointment info card
              Card(
                color: isDark
                    ? Colors.green.shade900.withOpacity(0.3)
                    : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Thông tin lịch hẹn',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Dịch vụ',
                        widget.appointment.serviceTitle ?? 'Không có',
                      ),
                      _buildInfoRow('Thú cưng', widget.pet.name),
                      _buildInfoRow(
                        'Thời gian',
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      _buildInfoRow('Trạng thái', 'Hoàn thành'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề hồ sơ *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Record type
              DropdownButtonFormField<String>(
                value: _selectedRecordType,
                decoration: const InputDecoration(
                  labelText: 'Loại hồ sơ *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _recordTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getRecordTypeDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRecordType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày khám *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cost
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chi phí (VNĐ)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),

              const SizedBox(height: 16),

              // Next visit date
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày tái khám',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                  ),
                  child: Text(
                    _nextVisitDate != null
                        ? '${_nextVisitDate!.day}/${_nextVisitDate!.month}/${_nextVisitDate!.year}'
                        : 'Chọn ngày',
                    style: TextStyle(
                      fontSize: 16,
                      color: _nextVisitDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Chẩn đoán & Điều trị *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập chẩn đoán và điều trị';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú bác sĩ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Lưu hồ sơ y tế',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getRecordTypeDisplayName(String type) {
    switch (type) {
      case 'checkup':
        return 'Khám định kỳ';
      case 'vaccination':
        return 'Tiêm chủng';
      case 'treatment':
        return 'Điều trị';
      case 'surgery':
        return 'Phẫu thuật';
      case 'test':
        return 'Xét nghiệm';
      default:
        return type;
    }
  }
}
