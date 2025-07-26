import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/model/MedicalRecordModel.dart';
import '../../../../data/model/PetModel.dart';
import '../homeScreen/UserHomeViewModel.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final PetModel pet;
  final MedicalRecordModel? record; // null nếu thêm mới, có giá trị nếu sửa

  const AddMedicalRecordScreen({super.key, required this.pet, this.record});

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _costController = TextEditingController();
  final _doctorNameController = TextEditingController();

  String _selectedRecordType = 'checkup';
  String _selectedStatus = 'completed';
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextVisitDate;

  final List<String> _recordTypes = [
    'checkup',
    'vaccination',
    'treatment',
    'surgery',
    'test',
  ];

  final List<String> _statuses = [
    'completed',
    'ongoing',
    'scheduled',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      // Chế độ sửa
      _titleController.text = widget.record!.title;
      _descriptionController.text = widget.record!.description;
      _notesController.text = widget.record!.notes ?? '';
      _costController.text = widget.record!.cost?.toString() ?? '';
      _doctorNameController.text = widget.record!.doctorName ?? '';
      _selectedRecordType = widget.record!.recordType;
      _selectedStatus = widget.record!.status;
      _selectedDate = widget.record!.recordDate;
      _nextVisitDate = widget.record!.nextVisitDate != null
          ? DateTime.parse(widget.record!.nextVisitDate!)
          : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _costController.dispose();
    _doctorNameController.dispose();
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
      final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);

      final record = MedicalRecordModel(
        id: widget.record?.id ?? const Uuid().v4(),
        petId: widget.pet.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        recordType: _selectedRecordType,
        recordDate: _selectedDate,
        doctorName: _doctorNameController.text.trim().isEmpty
            ? null
            : _doctorNameController.text.trim(),
        status: _selectedStatus,
        cost: _costController.text.isNotEmpty
            ? double.tryParse(_costController.text)
            : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        nextVisitDate: _nextVisitDate?.toIso8601String().split('T')[0],
        createdAt: widget.record?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await viewModel.addMedicalRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.record != null
                  ? 'Cập nhật hồ sơ thành công!'
                  : 'Thêm hồ sơ thành công!',
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
          widget.record != null ? 'Sửa hồ sơ y tế' : 'Thêm hồ sơ y tế',
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

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề *',
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

              // Doctor name
              TextFormField(
                controller: _doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Bác sĩ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                items: _statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusDisplayName(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
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
                          ? Colors.black
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
                  labelText: 'Mô tả *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mô tả';
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
                  labelText: 'Ghi chú',
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
                  child: Text(
                    widget.record != null ? 'Cập nhật' : 'Thêm hồ sơ',
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

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'completed':
        return 'Hoàn thành';
      case 'ongoing':
        return 'Đang thực hiện';
      case 'scheduled':
        return 'Đã lên lịch';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}
