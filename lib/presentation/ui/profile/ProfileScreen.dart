import 'package:flutter/material.dart';
import 'package:petcare/services/noti_service.dart';
import 'package:petcare/presentation/ui/settings/SettingsScreen.dart';
import 'package:provider/provider.dart';
import 'package:petcare/presentation/ui/auth/AuthViewModel.dart';
import 'package:petcare/presentation/ui/user/homeScreen/UserHomeViewModel.dart';
import 'package:petcare/presentation/ui/user/petScreen/PetDetailScreen.dart';
import 'package:petcare/presentation/ui/user/petScreen/AllMedicalRecordsScreen.dart';
import 'package:petcare/presentation/ui/user/serviceScreen/AllServiceHistoryScreen.dart';
import 'package:petcare/presentation/ui/profile/EditProfileScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../l10n/app_localizations.dart';

import '../auth/LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileAvatarUrl;
  String? _profileDisplayName;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).checkCurrentUser();
      Provider.of<UserHomeViewModel>(context, listen: false).fetchPets();
      _fetchProfile();
    });
  }

  Future<void> _fetchProfile() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;
      final data = await client
          .from('profiles')
          .select('name, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      if (!mounted) return;
      setState(() {
        _profileDisplayName = (data?['name'] as String?)?.trim().isNotEmpty == true
            ? data!['name'] as String
            : null;
        _profileAvatarUrl = data?['avatar_url'] as String?;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.personal_profile,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthViewModel, UserHomeViewModel>(
        builder: (context, authViewModel, petViewModel, child) {
          // Kiểm tra trạng thái loading của cả hai view model
          if (authViewModel.isLoading || petViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          // Kiểm tra user
          if (authViewModel.user == null) {
            return Center(child: Text(AppLocalizations.of(context)!.user_not_found));
          }

          // Lấy thông tin từ AuthViewModel
          final userName = _profileDisplayName ?? authViewModel.user!.name ?? AppLocalizations.of(context)!.user;
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
                          colors: [Colors.green.shade300, Colors.green.shade100],
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
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileAvatarUrl != null && _profileAvatarUrl!.isNotEmpty
                              ? NetworkImage(_profileAvatarUrl!)
                              : const NetworkImage('https://i.pravatar.cc/150?img=3'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(userEmail, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                            userRole == 'doctor' ? AppLocalizations.of(context)!.veterinarian : AppLocalizations.of(context)!.pet_lover,
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
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                        if (updated == true) {
                          // Refresh pets and auth if needed
                          Provider.of<AuthViewModel>(context, listen: false).checkCurrentUser();
                          Provider.of<UserHomeViewModel>(context, listen: false).fetchPets(forceRefresh: true);
                          await _fetchProfile();
                        }
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(AppLocalizations.of(context)!.edit_profile),
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
                    label: AppLocalizations.of(context)!.pets,
                    value: petCount,
                    color: Colors.orange,
                  ),
                  _buildQuickStat(
                    icon: Icons.medical_services,
                    label: AppLocalizations.of(context)!.services,
                    value: '12', // TODO: Lấy từ Supabase
                    color: Colors.blue,
                  ),
                  _buildQuickStat(
                    icon: Icons.favorite,
                    label: AppLocalizations.of(context)!.health,
                    value: AppLocalizations.of(context)!.good, // TODO: Lấy từ Supabase
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
                title: AppLocalizations.of(context)!.pet_management,
                subtitle: AppLocalizations.of(context)!.view_edit_pet_profiles,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PetDetailScreen()));
                },
              ),
              _buildProfileCard(
                context,
                icon: Icons.history,
                iconBg: Colors.blue.shade100,
                iconColor: Colors.blue,
                title: AppLocalizations.of(context)!.service_history,
                subtitle: AppLocalizations.of(context)!.view_service_booking_history,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllServiceHistoryScreen(),
                    ),
                  );
                },
              ),
              _buildProfileCard(
                context,
                icon: Icons.medical_services,
                iconBg: Colors.green.shade100,
                iconColor: Colors.green,
                title: AppLocalizations.of(context)!.medical_records,
                subtitle: AppLocalizations.of(context)!.store_exam_test_results,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllMedicalRecordsScreen(),
                    ),
                  );
                },
              ),
              _buildProfileCard(
                context,
                icon: Icons.bar_chart,
                iconBg: Colors.purple.shade100,
                iconColor: Colors.purple,
                title: AppLocalizations.of(context)!.health_statistics,
                subtitle: AppLocalizations.of(context)!.track_pet_health,
                onTap: () {},
              ),
              _buildProfileCard(
                context,
                icon: Icons.restaurant,
                iconBg: Colors.red.shade100,
                iconColor: Colors.red,
                title: AppLocalizations.of(context)!.nutrition,
                subtitle: AppLocalizations.of(context)!.menu_nutrition_suggestions,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              Divider(),
              _buildProfileCard(
                context,
                icon: Icons.logout,
                iconBg: Colors.grey.shade200,
                iconColor: Colors.red,
                title: AppLocalizations.of(context)!.logout,
                subtitle: AppLocalizations.of(context)!.exit_account,
                onTap: () async {
                  await Provider.of<AuthViewModel>(context, listen: false).signOutUser();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
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
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
        ),
        Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
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
      color: Theme.of(context).colorScheme.surface,
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
