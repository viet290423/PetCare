import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../mapper/Icon_Mapper.dart';
import '../../auth/AuthViewModel.dart';
import '../../auth/LoginScreen.dart';
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
      await serviceViewModel.fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceViewModel = Provider.of<ServicesViewModel>(context);
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
        child: SingleChildScrollView(
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
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
                serviceViewModel.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    )
                    : serviceViewModel.error != null
                    ? Center(child: Text('Lỗi: ${serviceViewModel.error}'))
                    : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: serviceViewModel.services.length.clamp(0, 4),
                      // hiển thị tối đa 4 dịch vụ
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
                      onTap: () {},
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final diseases = [
                      {
                        'title': 'Bệnh Dại',
                        'description':
                            'Bệnh truyền nhiễm nguy hiểm, cần tiêm phòng định kỳ',
                        'icon': Icons.warning,
                      },
                      {
                        'title': 'Bệnh Parvo',
                        'description':
                            'Bệnh đường ruột nguy hiểm ở chó, cần phát hiện sớm',
                        'icon': Icons.sick,
                      },
                      {
                        'title': 'Bệnh Giun Sán',
                        'description':
                            'Ký sinh trùng phổ biến, cần tẩy giun định kỳ',
                        'icon': Icons.bug_report,
                      },
                    ];
                    final disease = diseases[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          disease['icon'] as IconData,
                          color: Colors.green,
                        ),
                        title: Text(
                          disease['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(disease['description'] as String),
                      ),
                    );
                  },
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
}
