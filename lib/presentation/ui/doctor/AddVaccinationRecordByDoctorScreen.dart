import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../data/model/VaccinationRecordModel.dart';
import '../../../data/model/AppointmentModel.dart';
import '../../../data/model/PetModel.dart';
import 'AppointmentViewModel.dart';

class AddVaccinationRecordByDoctorScreen extends StatefulWidget {
  final AppointmentModel appointment;
  final PetModel pet;

  const AddVaccinationRecordByDoctorScreen({
    super.key,
    required this.appointment,
    required this.pet,
  });

  @override
  State<AddVaccinationRecordByDoctorScreen> createState() =>
      _AddVaccinationRecordByDoctorScreenState();
}

class _AddVaccinationRecordByDoctorScreenState
    extends State<AddVaccinationRecordByDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineNameController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedVaccineType = 'core';
  DateTime _vaccinationDate = DateTime.now();
  DateTime? _nextDueDate;

  final List<String> _vaccineTypes = ['core', 'non-core', 'rabies', 'other'];

  @override
  void initState() {
    super.initState();
    // Tự động điền thông tin từ appointment
    _vaccineNameController.text =
        widget.appointment.serviceTitle ?? 'Tiêm chủng';
    _vaccinationDate = widget.appointment.appointmentTime;

    // Tự động tính ngày tiêm nhắc lại
    _calculateNextDueDate();
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _batchNumberController.dispose();
    _manufacturerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateNextDueDate() {
    if (_selectedVaccineType == 'rabies') {
      _nextDueDate = DateTime(
        _vaccinationDate.year + 1,
        _vaccinationDate.month,
        _vaccinationDate.day,
      );
    } else if (_selectedVaccineType == 'core') {
      _nextDueDate = DateTime(
        _vaccinationDate.year + 1,
        _vaccinationDate.month,
        _vaccinationDate.day,
      );
    } else {
      _nextDueDate = null;
    }
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context, bool isNextDue) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isNextDue
          ? _nextDueDate ?? DateTime.now()
          : _vaccinationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isNextDue) {
          _nextDueDate = picked;
        } else {
          _vaccinationDate = picked;
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

      final record = VaccinationRecordModel(
        id: const Uuid().v4(),
        petId: widget.pet.id,
        vaccineName: _vaccineNameController.text.trim(),
        vaccineType: _selectedVaccineType,
        vaccinationDate: _vaccinationDate,
        nextDueDate: _nextDueDate,
        batchNumber: _batchNumberController.text.trim().isEmpty
            ? null
            : _batchNumberController.text.trim(),
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? null
            : _manufacturerController.text.trim(),
        administeredBy: widget.appointment.doctorName,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: 'completed',
        createdAt: DateTime.now(),
      );

      // TODO: Implement add vaccination record use case for doctor
      // await appointmentViewModel.addVaccinationRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm lịch sử tiêm chủng thành công!'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm lịch sử tiêm chủng'),
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
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.vaccines, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Thông tin tiêm chủng',
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
                        widget.appointment.serviceTitle ?? 'Tiêm chủng',
                      ),
                      _buildInfoRow('Thú cưng', widget.pet.name),
                      _buildInfoRow(
                        'Thời gian',
                        '${_vaccinationDate.day}/${_vaccinationDate.month}/${_vaccinationDate.year}',
                      ),
                      _buildInfoRow(
                        'Bác sĩ',
                        widget.appointment.doctorName ?? 'Không có',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Vaccine name
              TextFormField(
                controller: _vaccineNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên vaccine *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vaccines),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên vaccine';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Vaccine type
              DropdownButtonFormField<String>(
                value: _selectedVaccineType,
                decoration: const InputDecoration(
                  labelText: 'Loại vaccine *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _vaccineTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getVaccineTypeDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVaccineType = value!;
                  });
                  _calculateNextDueDate();
                },
              ),

              const SizedBox(height: 16),

              // Vaccination date
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày tiêm *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_vaccinationDate.day}/${_vaccinationDate.month}/${_vaccinationDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Next due date
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày tiêm nhắc lại',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                  ),
                  child: Text(
                    _nextDueDate != null
                        ? '${_nextDueDate!.day}/${_nextDueDate!.month}/${_nextDueDate!.year}'
                        : 'Chọn ngày',
                    style: TextStyle(
                      fontSize: 16,
                      color: _nextDueDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Manufacturer
              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(
                  labelText: 'Nhà sản xuất',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),

              const SizedBox(height: 16),

              // Batch number
              TextFormField(
                controller: _batchNumberController,
                decoration: const InputDecoration(
                  labelText: 'Số lô',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
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

              // Vaccine schedule info
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Lịch tiêm chủng khuyến nghị',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildVaccineScheduleItem(
                        'Core vaccines',
                        '6-8 tuần, 10-12 tuần, 14-16 tuần, 1 năm',
                      ),
                      _buildVaccineScheduleItem(
                        'Rabies',
                        '12-16 tuần, nhắc lại hàng năm',
                      ),
                      _buildVaccineScheduleItem(
                        'Non-core',
                        'Theo khuyến nghị của bác sĩ',
                      ),
                    ],
                  ),
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
                    'Lưu lịch sử tiêm chủng',
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

  String _getVaccineTypeDisplayName(String type) {
    switch (type) {
      case 'core':
        return 'Vaccine cốt lõi';
      case 'non-core':
        return 'Vaccine bổ sung';
      case 'rabies':
        return 'Vaccine dại';
      case 'other':
        return 'Vaccine khác';
      default:
        return type;
    }
  }

  Widget _buildVaccineScheduleItem(String label, String schedule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(schedule)),
        ],
      ),
    );
  }
}
