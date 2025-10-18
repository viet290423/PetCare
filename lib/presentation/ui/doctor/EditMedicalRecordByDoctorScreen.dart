import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../data/model/MedicalRecordModel.dart';
import '../../../domain/usecase/pet/UpdateMedicalRecordUseCase.dart';

class EditMedicalRecordByDoctorScreen extends StatefulWidget {
  final MedicalRecordModel record;

  const EditMedicalRecordByDoctorScreen({super.key, required this.record});

  @override
  State<EditMedicalRecordByDoctorScreen> createState() => _EditMedicalRecordByDoctorScreenState();
}

class _EditMedicalRecordByDoctorScreenState extends State<EditMedicalRecordByDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  late final TextEditingController _costController;

  late String _selectedRecordType;
  late DateTime _selectedDate;
  DateTime? _nextVisitDate;

  final List<String> _recordTypes = const ['checkup','vaccination','treatment','surgery','test'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.record.title);
    _descriptionController = TextEditingController(text: widget.record.description);
    _notesController = TextEditingController(text: widget.record.notes ?? '');
    _costController = TextEditingController(text: widget.record.cost?.toString() ?? '');

    _selectedRecordType = widget.record.recordType;
    _selectedDate = widget.record.recordDate;
    if (widget.record.nextVisitDate != null && widget.record.nextVisitDate!.isNotEmpty) {
      try {
        _nextVisitDate = DateTime.parse(widget.record.nextVisitDate!);
      } catch (_) {
        _nextVisitDate = null;
      }
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

  Future<void> _selectDate(BuildContext context, {required bool isNextVisit}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isNextVisit ? (_nextVisitDate ?? DateTime.now()) : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updated = MedicalRecordModel(
        id: widget.record.id,
        petId: widget.record.petId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        recordType: _selectedRecordType,
        recordDate: _selectedDate,
        doctorId: widget.record.doctorId,
        doctorName: widget.record.doctorName,
        status: widget.record.status,
        cost: _costController.text.isNotEmpty ? double.tryParse(_costController.text) : null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        attachments: widget.record.attachments,
        vitals: widget.record.vitals,
        medications: widget.record.medications,
        nextVisitDate: _nextVisitDate != null ? _nextVisitDate!.toIso8601String().split('T')[0] : null,
        createdAt: widget.record.createdAt,
        updatedAt: DateTime.now(),
      );

      final useCase = GetIt.I<UpdateMedicalRecordUseCase>();
      final result = await useCase(updated);
      result.fold((err) => throw Exception(err), (_) => null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ y tế thành công!'), backgroundColor: Colors.green),
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
        title: const Text('Sửa hồ sơ y tế', style: TextStyle(fontWeight: FontWeight.bold)),
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề hồ sơ *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRecordType,
                decoration: const InputDecoration(
                  labelText: 'Loại hồ sơ *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _recordTypes.map((t) => DropdownMenuItem(value: t, child: Text(_displayType(t)))).toList(),
                onChanged: (v) => setState(() => _selectedRecordType = v ?? 'checkup'),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context, isNextVisit: false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày khám *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
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
              InkWell(
                onTap: () => _selectDate(context, isNextVisit: true),
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
                      color: _nextVisitDate != null ? Theme.of(context).colorScheme.onSurface : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Chẩn đoán & Điều trị *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập chẩn đoán và điều trị' : null,
              ),
              const SizedBox(height: 16),
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Lưu thay đổi', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayType(String t) {
    switch (t) {
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
        return t;
    }
  }
}
