import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:petcare/presentation/ui/doctor/homeScreen/DoctorHomeScreen.dart';
import 'package:petcare/presentation/ui/doctor/DoctorScheduleScreen.dart';
import 'package:petcare/presentation/ui/doctor/DoctorStatsScreen.dart';
import 'package:petcare/presentation/ui/doctor/MedicalRecordsScreen.dart';
import 'package:petcare/presentation/ui/user/homeScreen/UserHomeScreen.dart';
import 'package:petcare/presentation/ui/user/petScreen/PetScreen.dart';
import 'package:petcare/presentation/ui/user/serviceScreen/ServiceScreen.dart';
import 'package:petcare/presentation/ui/library/LibraryScreen.dart';
import 'package:petcare/presentation/ui/community/CommunityScreen.dart';
import 'package:petcare/presentation/ui/profile/ProfileScreen.dart';
import 'package:petcare/presentation/ui/user/homeScreen/UserHomeScreen.dart';

import '../../../domain/entity/AuthUser.dart';

class MainScreen extends StatefulWidget {
  final AuthUser user;

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = widget.user.role == 'doctor';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildPage(_currentIndex, isDoctor),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.5 : 0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            selectedIndex: _currentIndex,
            backgroundColor: Theme.of(context).colorScheme.surface,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            activeColor: Theme.of(context).colorScheme.primary,
            tabBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
            rippleColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.10),
            gap: 5,
            tabs: isDoctor
                ? const [
                    GButton(
                      icon: Iconsax.home,
                      iconSize: 30,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    GButton(
                      icon: Iconsax.calendar,
                      iconSize: 30,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    GButton(
                      icon: Iconsax.chart_2,
                      iconSize: 30,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    GButton(
                      icon: Iconsax.direct,
                      iconSize: 30,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    GButton(
                      icon: Iconsax.user,
                      iconSize: 30,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                  ]
                : const [
                    GButton(
                      icon: Iconsax.home,
                      iconSize: 30,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    GButton(
                      icon: Iconsax.heart_circle,
                      iconSize: 30,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    GButton(
                      icon: Iconsax.health,
                      iconSize: 30,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    GButton(
                      icon: Iconsax.profile_2user,
                      iconSize: 30,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    GButton(
                      icon: Iconsax.user,
                      iconSize: 30,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                  ],
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index, bool isDoctor) {
    if (isDoctor) {
      switch (index) {
        case 0:
          return DoctorHomeScreen();
        case 1:
          return DoctorScheduleScreen();

        case 2:
          return DoctorStatsScreen();

        case 3:
          return MedicalRecordsScreen();

        case 4:
          return ProfileScreen();

        default:
          return DoctorHomeScreen();
      }
    } else {
      switch (index) {
        case 0:
          return UserHomeScreen(onTabNavigate: (i) => navigateToTab(i));
        case 1:
          return PetScreen();

        case 2:
          return ServicesScreen();

        case 3:
          return CommunityScreen();

        case 4:
          return ProfileScreen();

        default:
          return UserHomeScreen();
      }
    }
  }
}
