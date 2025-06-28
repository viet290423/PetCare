import 'package:flutter/material.dart';
import 'package:petcare/services/noti_service.dart';
import 'package:provider/provider.dart';
import 'package:petcare/presentation/ui/auth/AuthViewModel.dart';
import 'package:petcare/presentation/ui/user/homeScreen/UserHomeViewModel.dart';
import 'package:petcare/presentation/ui/user/petScreen/PetDetailScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).checkCurrentUser();
      Provider.of<UserHomeViewModel>(context, listen: false).fetchPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              NotiService().scheduleNotification(
                title: 'Thông báo',
                body: 'Đây là thông báo từ PetCare',
                hour: 16,
                minute: 40,
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthViewModel, UserHomeViewModel>(
        builder: (context, authViewModel, petViewModel, child) {
          // Kiểm tra trạng thái loading của cả hai view model
          if (authViewModel.isLoading || petViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          // Kiểm tra user
          if (authViewModel.user == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin người dùng'),
            );
          }

          // Lấy thông tin từ AuthViewModel
          final userName = authViewModel.user!.name ?? 'Người dùng';
          final userEmail = authViewModel.user!.email;
          final userRole = authViewModel.user!.role;
          final petCount = petViewModel.pets.length.toString();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Avatar + tên + email + badge
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade300,
                            Colors.green.shade100,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          // TODO: Thay bằng avatarUrl từ Supabase nếu có
                          backgroundImage: const NetworkImage(
                            'https://i.pravatar.cc/150?img=3',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pets, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            userRole == 'doctor' ? 'Bác sĩ thú y' : 'Pet Lover',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Chuyển đến màn chỉnh sửa hồ sơ
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Chỉnh sửa hồ sơ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Overview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickStat(
                    icon: Icons.pets,
                    label: 'Thú cưng',
                    value: petCount,
                    color: Colors.orange,
                  ),
                  _buildQuickStat(
                    icon: Icons.medical_services,
                    label: 'Dịch vụ',
                    value: '12', // TODO: Lấy từ Supabase
                    color: Colors.blue,
                  ),
                  _buildQuickStat(
                    icon: Icons.favorite,
                    label: 'Sức khỏe',
                    value: 'Tốt', // TODO: Lấy từ Supabase
                    color: Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Các chức năng chính
              _buildProfileCard(
                context,
                icon: Icons.pets,
                iconBg: Colors.orange.shade100,
                iconColor: Colors.orange,
                title: 'Quản lý thú cưng',
                subtitle: 'Xem & chỉnh sửa hồ sơ thú cưng',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PetDetailScreen()),
                  );
                },
              ),
              _buildProfileCard(
                context,
                icon: Icons.history,
                iconBg: Colors.blue.shade100,
                iconColor: Colors.blue,
                title: 'Lịch sử dịch vụ',
                subtitle: 'Xem lịch sử đặt dịch vụ',
                onTap: () {},
              ),
              _buildProfileCard(
                context,
                icon: Icons.medical_services,
                iconBg: Colors.green.shade100,
                iconColor: Colors.green,
                title: 'Hồ sơ y tế',
                subtitle: 'Lưu trữ kết quả khám, xét nghiệm',
                onTap: () {},
              ),
              _buildProfileCard(
                context,
                icon: Icons.bar_chart,
                iconBg: Colors.purple.shade100,
                iconColor: Colors.purple,
                title: 'Thống kê sức khỏe',
                subtitle: 'Theo dõi sức khỏe thú cưng',
                onTap: () {},
              ),
              _buildProfileCard(
                context,
                icon: Icons.restaurant,
                iconBg: Colors.red.shade100,
                iconColor: Colors.red,
                title: 'Dinh dưỡng',
                subtitle: 'Gợi ý thực đơn, dinh dưỡng',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              Divider(),
              _buildProfileCard(
                context,
                icon: Icons.logout,
                iconBg: Colors.grey.shade200,
                iconColor: Colors.red,
                title: 'Đăng xuất',
                subtitle: 'Thoát tài khoản',
                onTap: () async {
                  await Provider.of<AuthViewModel>(
                    context,
                    listen: false,
                  ).signOutUser();
                  // TODO: Điều hướng về màn đăng nhập sau khi đăng xuất
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconBg,
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
