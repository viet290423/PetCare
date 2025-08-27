import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/model/HealthMetricsModel.dart';
import '../../../../data/model/PetModel.dart';
import '../homeScreen/UserHomeViewModel.dart';

class AddHealthMetricsScreen extends StatefulWidget {
  final PetModel pet;
  final HealthMetricsModel? metrics; // null nếu thêm mới, có giá trị nếu sửa

  const AddHealthMetricsScreen({super.key, required this.pet, this.metrics});

  @override
  State<AddHealthMetricsScreen> createState() => _AddHealthMetricsScreenState();
}

class _AddHealthMetricsScreenState extends State<AddHealthMetricsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _bloodPressureSystolicController = TextEditingController();
  final _bloodPressureDiastolicController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.metrics != null) {
      // Chế độ sửa
      _weightController.text = widget.metrics!.weight?.toString() ?? '';
      _temperatureController.text =
          widget.metrics!.temperature?.toString() ?? '';
      _heartRateController.text = widget.metrics!.heartRate?.toString() ?? '';
      _respiratoryRateController.text =
          widget.metrics!.respiratoryRate?.toString() ?? '';
      _bloodPressureSystolicController.text =
          widget.metrics!.bloodPressureSystolic?.toString() ?? '';
      _bloodPressureDiastolicController.text =
          widget.metrics!.bloodPressureDiastolic?.toString() ?? '';
      _notesController.text = widget.metrics!.notes ?? '';
      _selectedDate = widget.metrics!.date;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _temperatureController.dispose();
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _bloodPressureSystolicController.dispose();
    _bloodPressureDiastolicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMetrics() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);

      final metrics = HealthMetricsModel(
        id: widget.metrics?.id ?? const Uuid().v4(),
        petId: widget.pet.id,
        date: _selectedDate,
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        temperature: _temperatureController.text.isNotEmpty
            ? double.tryParse(_temperatureController.text)
            : null,
        heartRate: _heartRateController.text.isNotEmpty
            ? int.tryParse(_heartRateController.text)
            : null,
        respiratoryRate: _respiratoryRateController.text.isNotEmpty
            ? int.tryParse(_respiratoryRateController.text)
            : null,
        bloodPressureSystolic: _bloodPressureSystolicController.text.isNotEmpty
            ? double.tryParse(_bloodPressureSystolicController.text)
            : null,
        bloodPressureDiastolic:
            _bloodPressureDiastolicController.text.isNotEmpty
            ? double.tryParse(_bloodPressureDiastolicController.text)
            : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.metrics?.createdAt ?? DateTime.now(),
      );

      await viewModel.addHealthMetrics(metrics);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.metrics != null
                  ? 'Cập nhật chỉ số thành công!'
                  : 'Thêm chỉ số thành công!',
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
          widget.metrics != null
              ? 'Sửa chỉ số sức khỏe'
              : 'Thêm chỉ số sức khỏe',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          )
        ),
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

              // Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày đo *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cân nặng (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                  suffixText: 'kg',
                ),
              ),

              const SizedBox(height: 16),

              // Temperature
              TextFormField(
                controller: _temperatureController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nhiệt độ (°C)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.thermostat),
                  suffixText: '°C',
                ),
              ),

              const SizedBox(height: 16),

              // Heart Rate
              TextFormField(
                controller: _heartRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nhịp tim (nhịp/phút)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.favorite),
                  suffixText: 'bpm',
                ),
              ),

              const SizedBox(height: 16),

              // Respiratory Rate
              TextFormField(
                controller: _respiratoryRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nhịp thở (nhịp/phút)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.air),
                  suffixText: 'bpm',
                ),
              ),

              const SizedBox(height: 16),

              // Blood Pressure
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bloodPressureSystolicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Huyết áp tâm thu',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.favorite_border),
                        suffixText: 'mmHg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _bloodPressureDiastolicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Huyết áp tâm trương',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.favorite_border),
                        suffixText: 'mmHg',
                      ),
                    ),
                  ),
                ],
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

              // Normal ranges info
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
                            'Chỉ số bình thường',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildNormalRangeItem('Nhiệt độ', '37.5 - 39.2°C'),
                      _buildNormalRangeItem('Nhịp tim', '60 - 140 bpm'),
                      _buildNormalRangeItem('Nhịp thở', '10 - 30 bpm'),
                      _buildNormalRangeItem(
                        'Huyết áp',
                        '110/60 - 160/100 mmHg',
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
                  onPressed: _saveMetrics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.metrics != null ? 'Cập nhật' : 'Thêm chỉ số',
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

  Widget _buildNormalRangeItem(String label, String range) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
          Text(range, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
