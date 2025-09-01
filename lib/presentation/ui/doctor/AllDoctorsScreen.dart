import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/model/DoctorModel.dart';
import 'homeScreen/DoctorViewModel.dart';
import 'DoctorDetailScreen.dart';

class AllDoctorsScreen extends StatefulWidget {
  const AllDoctorsScreen({Key? key}) : super(key: key);

  @override
  State<AllDoctorsScreen> createState() => _AllDoctorsScreenState();
}

class _AllDoctorsScreenState extends State<AllDoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialization = 'Tất cả';
  List<String> _specializations = ['Tất cả'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorViewModel = Provider.of<DoctorViewModel>(
        context,
        listen: false,
      );
      doctorViewModel.fetchDoctors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đội Ngũ Bác Sĩ', style: TextStyle(fontWeight: FontWeight.bold)),
        // backgroundColor: Colors.green,
        // foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<DoctorViewModel>(
        builder: (context, doctorViewModel, child) {
          if (doctorViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }

          if (doctorViewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${doctorViewModel.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      doctorViewModel.fetchDoctors();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Cập nhật danh sách chuyên ngành
          _updateSpecializations(doctorViewModel.doctors);

          // Lọc bác sĩ theo tìm kiếm và chuyên ngành
          final filteredDoctors = _getFilteredDoctors(doctorViewModel.doctors);

          return Column(
            children: [
              // Search và Filter
              Container(
                padding: const EdgeInsets.all(16),
                // color: Colors.green.shade50,
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm bác sĩ...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),

                        // Border khi chưa focus
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),

                        // Border khi focus
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green, // màu khi focus
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 12),

                    // Filter by specialization
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _specializations.length,
                        itemBuilder: (context, index) {
                          final specialization = _specializations[index];
                          final isSelected =
                              _selectedSpecialization == specialization;

                          return Container(
                            margin: EdgeInsets.only(
                              right:
                                  index == _specializations.length - 1 ? 0 : 8,
                            ),
                            child: FilterChip(
                              label: Text(specialization),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSpecialization = specialization;
                                });
                              },
                              selectedColor: Colors.green.shade100,
                              checkmarkColor: Colors.green,
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Doctors list
              Expanded(
                child:
                    filteredDoctors.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Không tìm thấy bác sĩ nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doctor = filteredDoctors[index];
                            return _buildDoctorCard(doctor);
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(doctor: doctor),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Doctor avatar
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green.shade100,
                child:
                    doctor.imageUrl.isNotEmpty
                        ? ClipOval(
                          child: Image.network(
                            doctor.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                doctor.name[0],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              );
                            },
                          ),
                        )
                        : Text(
                          doctor.name[0],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
              ),
              const SizedBox(width: 16),

              // Doctor info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialization,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.rating} (${doctor.reviewCount} đánh giá)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Experience
                    Text(
                      'Kinh nghiệm: ${doctor.experience}',
                      style: const TextStyle(fontSize: 12),
                    ),

                    // Availability status
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                doctor.isAvailable
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            doctor.isAvailable ? 'Có sẵn' : 'Bận',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  doctor.isAvailable
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Giờ làm: ${doctor.workingHours}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _updateSpecializations(List<DoctorModel> doctors) {
    final specializations = <String>{'Tất cả'};
    for (final doctor in doctors) {
      specializations.addAll(doctor.specializations);
    }
    _specializations = specializations.toList()..sort();
  }

  List<DoctorModel> _getFilteredDoctors(List<DoctorModel> doctors) {
    List<DoctorModel> filtered = doctors;

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      filtered =
          filtered
              .where(
                (doctor) =>
                    doctor.name.toLowerCase().contains(searchQuery) ||
                    doctor.specialization.toLowerCase().contains(searchQuery) ||
                    doctor.specializations.any(
                      (spec) => spec.toLowerCase().contains(searchQuery),
                    ) ||
                    doctor.description.toLowerCase().contains(searchQuery),
              )
              .toList();
    }

    // Filter by specialization
    if (_selectedSpecialization != 'Tất cả') {
      filtered =
          filtered
              .where(
                (doctor) =>
                    doctor.specializations.contains(_selectedSpecialization),
              )
              .toList();
    }

    return filtered;
  }
}
