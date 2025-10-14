import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare/presentation/ui/pet/PetViewModel.dart';
import 'package:petcare/presentation/ui/widget/CustomMyTextField.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../data/model/PetModel.dart';

class AddPetScreen extends StatefulWidget {
  final PetModel? pet;

  const AddPetScreen({super.key, this.pet});

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
  File? localImageFile;
  String imageUrl = '';
  String _selectedWeightUnit = 'kg';

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      // Initialize form with existing pet data
      _nameController.text = widget.pet!.name;
      _breedController.text = widget.pet!.breed;
      selectedType = widget.pet!.type;
      selectedGender = widget.pet!.gender;
      imageUrl = widget.pet!.imageUrl;

      // Parse weight
      final weightParts = widget.pet!.weight.split(' ');
      if (weightParts.length == 2) {
        _weightController.text = weightParts[0];
        _selectedWeightUnit = weightParts[1];
      }

      _colorController.text = widget.pet!.color;

      // Parse birth date
      if (widget.pet!.birthDate.isNotEmpty) {
        final parts = widget.pet!.birthDate.split('/');
        if (parts.length == 3) {
          selectedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
    }
  }

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
        // margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.transparent,
          border:
              isSelected
                  ? Border.all(color: Colors.green.shade300, width: 1.5)
                  : Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.green : Colors.black54,
            ),
            const SizedBox(height: 4),
            Text(type),
          ],
        ),
      ),
    );
  }

  Widget buildGenderButton(String gender, IconData icon) {
    final isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        // margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade200 : Colors.transparent,
          border:
              isSelected
                  ? Border.all(color: Colors.green.shade300, width: 1.5)
                  : Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.green : Colors.black),
            const SizedBox(width: 6),
            Text(
              gender,
              style: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitButton(String unit) {
    final bool isSelected = _selectedWeightUnit == unit;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedWeightUnit = unit;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
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
        centerTitle: true,
        title: Text(
          widget.pet != null ? 'Chỉnh sửa thú cưng' : 'Thêm thú cưng mới',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(CupertinoIcons.back, size: 30, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Ảnh
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() {
                      localImageFile = File(picked.path); // chỉ lưu file local
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green.shade100,
                  backgroundImage:
                      localImageFile != null
                          ? FileImage(localImageFile!) // dùng ảnh local
                          : (imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null),
                  child:
                      localImageFile == null
                          ? const Icon(
                            Icons.add_a_photo,
                            size: 30,
                            color: Colors.green,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tên thú cưng *",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  CustomMyTextField(
                    hintText: "Nhập tên thú cưng",
                    controller: _nameController,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Không được để trống' : null,
                  ),
                ],
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Giống",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  CustomMyTextField(
                    hintText: "Nhập giống thú cưng",
                    controller: _breedController,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Ngày sinh
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ngày sinh",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  CustomMyTextField(
                    hintText: "DD/MM/YYYY",
                    suffixIcon: const Icon(Icons.calendar_today),
                    controller: TextEditingController(
                      text:
                          selectedDate != null
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
                ],
              ),
              const SizedBox(height: 12),

              // Giới tính
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Giới tính",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      buildGenderButton('Đực', Icons.male),
                      SizedBox(width: 12),
                      buildGenderButton('Cái', Icons.female),
                      SizedBox(width: 12),
                      buildGenderButton('Không rõ', Icons.help),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cân nặng",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomMyTextField(
                          hintText: "Nhập cân nặng",
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildUnitButton('kg'),
                            _buildUnitButton('g'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Màu sắc",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  CustomMyTextField(
                    hintText: "Nhập màu sắc",
                    controller: _colorController,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ElevatedButton(
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
                child: Text(
                  widget.pet != null ? 'Cập nhật thông tin' : 'Lưu thú cưng',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (localImageFile != null) {
                      final uploadedUrl = await context
                          .read<PetViewModel>()
                          .uploadPetImage(localImageFile!);
                      if (uploadedUrl != null) {
                        imageUrl = uploadedUrl;
                      }
                    }
                    final pet = PetModel(
                      id: widget.pet?.id ?? const Uuid().v4(),
                      name: _nameController.text,
                      type: selectedType,
                      imageUrl: imageUrl,
                      breed: _breedController.text,
                      birthDate:
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : "",
                      weight: '${_weightController.text} $_selectedWeightUnit',
                      gender: selectedGender,
                      color: _colorController.text,
                    );
                    await viewModel.addPet(pet);
                    if (!mounted) return;
                    if (viewModel.error == null) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(viewModel.error ?? 'Thêm thú cưng thất bại')),
                      );
                    }
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
