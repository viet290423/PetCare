import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/model/VaccinationRecordModel.dart';
import '../../../../data/model/PetModel.dart';
import '../homeScreen/UserHomeViewModel.dart';

class AddVaccinationRecordScreen extends StatefulWidget {
  final PetModel pet;
  final VaccinationRecordModel? record; // null nếu thêm mới, có giá trị nếu sửa

  const AddVaccinationRecordScreen({super.key, required this.pet, this.record});

  @override
  State<AddVaccinationRecordScreen> createState() =>
      _AddVaccinationRecordScreenState();
}

class _AddVaccinationRecordScreenState
    extends State<AddVaccinationRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineNameController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _administeredByController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedVaccineType = 'core';
  DateTime _vaccinationDate = DateTime.now();
  DateTime? _nextDueDate;

  final List<String> _vaccineTypes = ['core', 'non-core', 'rabies', 'other'];

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      // Chế độ sửa
      _vaccineNameController.text = widget.record!.vaccineName;
      _batchNumberController.text = widget.record!.batchNumber ?? '';
      _manufacturerController.text = widget.record!.manufacturer ?? '';
      _administeredByController.text = widget.record!.administeredBy ?? '';
      _notesController.text = widget.record!.notes ?? '';
      _selectedVaccineType = widget.record!.vaccineType;
      _vaccinationDate = widget.record!.vaccinationDate;
      _nextDueDate = widget.record!.nextDueDate;
    }
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _batchNumberController.dispose();
    _manufacturerController.dispose();
    _administeredByController.dispose();
    _notesController.dispose();
    super.dispose();
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
      // Non-core vaccines typically don't have fixed schedules
      _nextDueDate = null;
    }
    setState(() {});
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);

      final record = VaccinationRecordModel(
        id: widget.record?.id ?? const Uuid().v4(),
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
        administeredBy: _administeredByController.text.trim().isEmpty
            ? null
            : _administeredByController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: 'completed',
        createdAt: widget.record?.createdAt ?? DateTime.now(),
      );

      await viewModel.addVaccinationRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.record != null
                  ? 'Cập nhật lịch sử tiêm chủng thành công!'
                  : 'Thêm lịch sử tiêm chủng thành công!',
            ),
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
        title: Text(
          widget.record != null
              ? 'Sửa lịch sử tiêm chủng'
              : 'Thêm lịch sử tiêm chủng',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(widget.pet.imageUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pet.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.pet.breed} • ${widget.pet.gender}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
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

              // Administered by
              TextFormField(
                controller: _administeredByController,
                decoration: const InputDecoration(
                  labelText: 'Người tiêm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),

              const SizedBox(height: 24),

              // Vaccine schedule info
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Lịch tiêm chủng khuyến nghị',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
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
                  child: Text(
                    widget.record != null
                        ? 'Cập nhật'
                        : 'Thêm lịch sử tiêm chủng',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
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
