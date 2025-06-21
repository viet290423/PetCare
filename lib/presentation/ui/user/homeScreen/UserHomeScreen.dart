import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/model/DiseaseModel.dart';
import '../../../../data/model/DoctorModel.dart';
import '../../../mapper/Icon_Mapper.dart';
import '../../auth/AuthViewModel.dart';
import '../../auth/LoginScreen.dart';
import '../../disease/DiseaseDetailScreen.dart';
import '../../disease/DiseaseViewModel.dart';
import '../../doctor/DoctorDetailScreen.dart';
import '../../doctor/DoctorViewModel.dart';
import '../serviceScreen/ServiceDetailScreen.dart';
import '../serviceScreen/ServiceViewModel.dart';

class UserHomeScreen extends StatefulWidget {
  final void Function(int index)? onTabNavigate;

  const UserHomeScreen({super.key, this.onTabNavigate});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final serviceViewModel = Provider.of<ServicesViewModel>(
        context,
        listen: false,
      );
      final diseaseViewModel = Provider.of<DiseaseViewModel>(
        context,
        listen: false,
      );
      final doctorViewModel = Provider.of<DoctorViewModel>(
        context,
        listen: false,
      );
      await Future.wait([
        serviceViewModel.fetchServices(),
        diseaseViewModel.fetchDiseases(),
        doctorViewModel.fetchDoctors(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Pet Care',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          GestureDetector(
            child: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.pets, color: Colors.white),
            ),
            onTap: () async {
              final authViewModel = context.read<AuthViewModel>();
              await authViewModel.signOutUser();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer3<ServicesViewModel, DiseaseViewModel, DoctorViewModel>(
          builder: (
            context,
            serviceViewModel,
            diseaseViewModel,
            doctorViewModel,
            child,
          ) {
            // Kiểm tra trạng thái loading của cả ba view model
            if (serviceViewModel.isLoading ||
                diseaseViewModel.isLoading ||
                doctorViewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              );
            }

            // Kiểm tra lỗi
            if (serviceViewModel.error != null) {
              return Center(child: Text('Lỗi: ${serviceViewModel.error}'));
            }
            if (diseaseViewModel.error != null) {
              return Center(child: Text('Lỗi: ${diseaseViewModel.error}'));
            }
            if (doctorViewModel.error != null) {
              return Center(child: Text('Lỗi: ${doctorViewModel.error}'));
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner giới thiệu
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/banner.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chăm Sóc Thú Cưng Chuyên Nghiệp',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Dịch vụ chăm sóc toàn diện cho thú cưng của bạn',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dịch vụ chăm sóc
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dịch Vụ Chăm Sóc',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.onTabNavigate?.call(2);
                          },
                          child: Text(
                            "Xem tất cả",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: serviceViewModel.services.length.clamp(0, 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, index) {
                        final service = serviceViewModel.services[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ServiceDetailScreen(service: service),
                              ),
                            );
                          },
                          child: _buildServiceCard(
                            icon: getIconFromName(service.icon),
                            title: service.title,
                            description: service.description,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Đội ngũ bác sĩ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Đội Ngũ Bác Sĩ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to all doctors screen
                          },
                          child: Text(
                            "Xem tất cả",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: doctorViewModel.doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = doctorViewModel.doctors[index];
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            DoctorDetailScreen(doctor: doctor),
                                  ),
                                );
                              },
                              child: _buildDoctorCard(doctor),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bệnh thường gặp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bệnh Thường Gặp',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to all diseases screen
                          },
                          child: Text(
                            "Xem tất cả",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        // Search bar
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm bệnh...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              // TODO: Implement search functionality
                            },
                          ),
                        ),
                        // Disease cards
                        ...diseaseViewModel.diseases
                            .take(3)
                            .map((disease) => _buildDiseaseCard(disease)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Liên hệ
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Liên Hệ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildContactItem(
                            Icons.location_on,
                            '123 Đường Phan Đình Giót, Hà Đông, Hà Nội',
                          ),
                          _buildContactItem(Icons.phone, '0123 456 789'),
                          _buildContactItem(Icons.email, 'contact@petcare.com'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(DiseaseModel disease) {
    Color severityColor;
    switch (disease.severity) {
      case 'high':
        severityColor = Colors.red;
        break;
      case 'medium':
        severityColor = Colors.orange;
        break;
      case 'low':
        severityColor = Colors.green;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiseaseDetailScreen(disease: disease),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: severityColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          disease.severity == 'high'
                              ? 'Nguy hiểm cao'
                              : disease.severity == 'medium'
                              ? 'Nguy hiểm trung bình'
                              : 'Nguy hiểm thấp',
                          style: TextStyle(
                            color: severityColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      disease.petType == 'both'
                          ? 'Chó & Mèo'
                          : disease.petType == 'dog'
                          ? 'Chó'
                          : 'Mèo',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                disease.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                disease.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '${disease.symptoms.length} triệu chứng chính',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Card(
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor image placeholder
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, size: 40, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Doctor name
            Text(
              doctor.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Specialization
            Text(
              doctor.specialization,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Experience
            Row(
              children: [
                Icon(Icons.work, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    doctor.experience,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Rating
            Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${doctor.rating} (${doctor.reviewCount})',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Book appointment button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to book appointment screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đặt lịch sẽ được cập nhật sớm!'),
                    ),
                  );
                },
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to book appointment screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tính năng đặt lịch sẽ được cập nhật sớm!',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Đặt lịch', style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
