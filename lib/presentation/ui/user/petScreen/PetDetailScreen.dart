import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/model/PetModel.dart';
import '../homeScreen/UserHomeViewModel.dart';
import '../../pet/AddPetScreen.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  int _currentPage = 0;
  late PageController _pageController;
  File? _pickedImage;
  bool _isLoading = false;
  bool _isLoadingPage = true;

  // Controllers for editing
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  String? _selectedType;
  String? _selectedGender;
  DateTime? _selectedBirthDate;

  final _formKey = GlobalKey<FormState>();

  Future<String?> _uploadPetImage(File file) async {
    try {
      final client = Supabase.instance.client;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final storagePath = 'uploads/$fileName';

      final bytes = await file.readAsBytes();
      final response = await client.storage
          .from('pet-images')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(upsert: false),
          );

      if (response.isEmpty) throw Exception('Không thể upload ảnh');

      final imageUrl = client.storage
          .from('pet-images')
          .getPublicUrl(storagePath);
      return imageUrl;
    } catch (e) {
      debugPrint('Lỗi khi upload ảnh: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95, initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoadingPage = true);
      final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
      await viewModel.fetchPets(forceRefresh: true);
      if (viewModel.pets.isNotEmpty && viewModel.selectedPetId == null) {
        viewModel.selectedPetId = viewModel.pets.first.id;
      }
      setState(() => _isLoadingPage = false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _showEditSheet(PetModel pet, UserHomeViewModel viewModel) {
    _pickedImage = null;
    _nameController.text = pet.name;
    _breedController.text = pet.breed;
    _weightController.text = pet.weight.toString();
    _colorController.text = pet.color;
    _selectedType = pet.type;
    _selectedGender = pet.gender;
    _selectedBirthDate = DateTime.tryParse(pet.birthDate);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: _buildEditForm(pet, viewModel),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveEdit(PetModel oldPet, UserHomeViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    String imageUrl = oldPet.imageUrl;
    if (_pickedImage != null) {
      final uploadedUrl = await _uploadPetImage(_pickedImage!);
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }
    }
    final updatedPet = PetModel(
      id: oldPet.id,
      name: _nameController.text.trim(),
      type: _selectedType ?? oldPet.type,
      imageUrl: imageUrl,
      breed: _breedController.text.trim(),
      birthDate: _selectedBirthDate != null
          ? _selectedBirthDate!.toIso8601String()
          : oldPet.birthDate,
      gender: _selectedGender ?? oldPet.gender,
      weight: _weightController.text.trim(),
      color: _colorController.text.trim(),
    );
    await viewModel.updatePet(updatedPet);
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        // backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Thông tin thú cưng",
          style: const TextStyle(fontWeight: FontWeight.bold,),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingPage
          ? const Center(child: CircularProgressIndicator())
          : Consumer<UserHomeViewModel>(
              builder: (context, viewModel, child) {
                final pets = viewModel.pets;
                if (pets.isEmpty) {
                  return const Center(child: Text('Bạn chưa có thú cưng nào.'));
                }
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 520,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: pets.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                            viewModel.selectedPetId = pets[index].id;
                          });
                        },
                        itemBuilder: (context, index) {
                          final pet = pets[index];
                          final isSelected = index == _currentPage;
                          return AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.5,
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.green, width: 4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.08),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 70,
                                        backgroundImage: NetworkImage(pet.imageUrl),
                                        backgroundColor: Colors.grey[200],
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Material(
                                        color: Colors.white,
                                        shape: const CircleBorder(),
                                        elevation: 2,
                                        child: InkWell(
                                          onTap: () => _showEditSheet(pet, viewModel),
                                          customBorder: const CircleBorder(),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.edit, color: Colors.green, size: 22),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  pet.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Colors.green[800],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Divider(
                                  color: Colors.green[100],
                                  thickness: 1,
                                  indent: 40,
                                  endIndent: 40,
                                ),
                                const SizedBox(height: 8),
                                _petInfoRow(Icons.pets, 'Loài', pet.type),
                                _petInfoRow(Icons.category, 'Giống', pet.breed),
                                _petInfoRow(Icons.cake, 'Ngày sinh', pet.birthDate),
                                _petInfoRow(Icons.male, 'Giới tính', pet.gender),
                                _petInfoRow(Icons.monitor_weight, 'Cân nặng', '${pet.weight}'),
                                _petInfoRow(Icons.color_lens, 'Màu lông', pet.color),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPageIndicator(pets.length),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPetScreen()),
          );
          if (result == true) {
            final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
            await viewModel.fetchPets(forceRefresh: true);
            setState(() {});
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
        tooltip: 'Thêm thú cưng',
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == i ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == i ? Colors.green : Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  Widget _buildEditForm(PetModel pet, UserHomeViewModel viewModel) {
    final types = ['Chó', 'Mèo', 'Chim', 'Cá', 'Khác'];
    final genders = ['Đực', 'Cái'];
    return AbsorbPointer(
      absorbing: _isLoading,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!) as ImageProvider
                          : NetworkImage(pet.imageUrl),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        onTap: _pickImage,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.camera_alt, color: Colors.green, size: 22),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Tên thú cưng', Icons.pets),
                validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedType = v),
                decoration: _inputDecoration('Loài', Icons.pets),
                validator: (v) => v == null ? 'Chọn loài' : null,
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _breedController,
                decoration: _inputDecoration('Giống', Icons.category),
                validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedBirthDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedBirthDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: _inputDecoration('Ngày sinh', Icons.cake),
                  child: Row(
                    children: [
                      Text(
                        _selectedBirthDate != null
                            ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                            : 'Chọn ngày sinh',
                        style: TextStyle(
                          color: _selectedBirthDate != null ? Colors.black : Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today, size: 18, color: Colors.green),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: genders.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
                decoration: _inputDecoration('Giới tính', Icons.male),
                validator: (v) => v == null ? 'Chọn giới tính' : null,
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Cân nặng (kg)', Icons.monitor_weight),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Không được để trống';
                  final num? w = num.tryParse(v);
                  if (w == null || w <= 0) return 'Cân nặng không hợp lệ';
                  return null;
                },
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _colorController,
                decoration: _inputDecoration('Màu lông', Icons.color_lens),
                validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _saveEdit(pet, viewModel),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save, color: Colors.white,),
                    label: Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.green),
                    label: Text('Hủy', style: TextStyle(color: Colors.green)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: Colors.green),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  Widget _petInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 32),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Text('$label:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
