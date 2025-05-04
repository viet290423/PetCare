import 'package:flutter/material.dart';
import 'package:petcare/presentation/ui/pet/PetViewModel.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../data/model/PetModel.dart';


class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();

  String selectedType = 'Chó';
  String selectedGender = 'Không rõ';
  DateTime? selectedDate;
  String imageUrl = '';

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Widget buildTypeButton(String type, IconData icon) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isSelected ? Colors.green : Colors.black54),
            const SizedBox(height: 4),
            Text(type),
          ],
        ),
      ),
    );
  }

  Widget buildGenderButton(String gender, IconData icon) {
    final isSelected = selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedGender = gender;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade200 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.green : Colors.black),
              const SizedBox(height: 4),
              Text(gender, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PetViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm thú cưng mới'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Ảnh
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green.shade100,
                child: Icon(Icons.add_a_photo, size: 30, color: Colors.green),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên thú cưng *'),
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 12),

              // Loại thú cưng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildTypeButton('Chó', Icons.pets),
                  buildTypeButton('Mèo', Icons.pets),
                  buildTypeButton('Chim', Icons.flutter_dash),
                  buildTypeButton('Cá', Icons.water),
                  buildTypeButton('Khác', Icons.help_outline),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Giống'),
              ),
              const SizedBox(height: 12),

              // Ngày sinh
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : '',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Giới tính
              Row(
                children: [
                  buildGenderButton('Đực', Icons.male),
                  buildGenderButton('Cái', Icons.female),
                  buildGenderButton('Không rõ', Icons.help),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Cân nặng',
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Màu sắc'),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Lưu thú cưng'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final pet = PetModel(
                      id: const Uuid().v4(),
                      name: _nameController.text,
                      imageUrl: imageUrl,
                      breed: _breedController.text,
                    );
                    await viewModel.addPet(pet);
                    if (mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
