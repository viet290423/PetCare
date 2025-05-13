import 'package:flutter/material.dart';
import 'package:petcare/presentation/ui/pet/PetViewModel.dart';
import 'package:petcare/presentation/ui/widget/CustomMyTextField.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../data/model/PetModel.dart';
import '../../../data/model/ReminderModel.dart';

class AddReminderScreen extends StatefulWidget {
  final List<PetModel> pets;

  const AddReminderScreen({super.key, required this.pets});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  PetModel? selectedPet;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Cho ăn';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _repeatType = 'Không lặp lại';

  final List<String> types = [
    'Cho ăn',
    'Thuốc',
    'Tiêm phòng',
    'Vệ sinh',
    'Thú y',
    'Khác',
  ];
  final List<String> repeatOptions = [
    'Không lặp lại',
    'Hàng ngày',
    'Hàng tuần',
    'Hàng tháng',
    'Hàng năm',
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() &&
        selectedPet != null &&
        _selectedDate != null &&
        _selectedTime != null) {
      final DateTime dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final reminder = ReminderModel(
        id: const Uuid().v4(),
        petId: selectedPet!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        dateTime: dateTime,
        repeatType: _repeatType,
      );

      final viewModel = context.read<PetViewModel>();
      await viewModel.addReminder(reminder);

      if (viewModel.error == null && context.mounted) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.error ?? 'Lỗi không xác định')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhắc nhở')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chọn thú cưng",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 95,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.pets.length,
                  itemBuilder: (context, index) {
                    final pet = widget.pets[index];
                    final isSelected = selectedPet?.id == pet.id;
                    return GestureDetector(
                      onTap: () => setState(() => selectedPet = pet),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.green.shade100
                                    : Colors.grey.shade100,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.green.shade300
                                      : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(pet.imageUrl),
                                radius: 25,
                              ),
                              const SizedBox(height: 5),
                              Text(pet.name),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // TextFormField(
              //   controller: _titleController,
              //   decoration: const InputDecoration(labelText: 'Tiêu đề *'),
              //   validator:
              //       (value) =>
              //           value == null || value.isEmpty
              //               ? 'Vui lòng nhập tiêu đề'
              //               : null,
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tiêu đề *",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  CustomMyTextField(
                    hintText: "Tiêu đề *",
                    controller: _titleController,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Vui lòng nhập tiêu đề'
                                : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mô tả",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  CustomMyTextField(
                    hintText: "Mô tả",
                    controller: _descriptionController,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children:
                    types
                        .map(
                          (type) => ChoiceChip(
                            selectedColor: Colors.green.shade300,
                            checkmarkColor: Colors.white,
                            label: Text(
                              type,
                              style: TextStyle(
                                color:
                                    _selectedType == type
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                            selected: _selectedType == type,
                            onSelected:
                                (_) => setState(() => _selectedType = type),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.green, width: 1),
                        backgroundColor: Colors.white, // màu nền
                        foregroundColor: Colors.black, // màu chữ và icon
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // bo góc
                        ),
                      ),
                      onPressed: _selectDate,
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                      ),
                      label: Text(
                        _selectedDate == null
                            ? 'Chọn ngày'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.green, width: 1),
                        backgroundColor: Colors.white, // màu nền
                        foregroundColor: Colors.black, // màu chữ và icon
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // bo góc
                        ),
                      ),
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time, color: Colors.black),
                      label: Text(
                        _selectedTime == null
                            ? 'Chọn giờ'
                            : _selectedTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _repeatType,
                decoration: const InputDecoration(
                  labelText: 'Lặp lại',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                items:
                    repeatOptions
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _repeatType = value!),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Thêm nhắc nhở',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
