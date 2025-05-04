import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:petcare/presentation/ui/doctor/DoctorHomeScreen.dart';
import 'package:petcare/presentation/ui/user/UserHomeScreen.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildPage(_currentIndex, isDoctor),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          // color: Colors.green,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            // backgroundColor: Colors.green,
            // color: Colors.grey[400],
            color: Colors.black,
            activeColor: Colors.green,
            tabBackgroundColor: Theme.of(context).colorScheme.onPrimary,
            gap: 5,
            tabs:
                isDoctor
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
                        icon: Iconsax.notification,
                        iconSize: 30,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      GButton(
                        icon: Iconsax.camera,
                        iconSize: 30,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      GButton(
                        icon: Iconsax.messages,
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
                        icon: Iconsax.notification,
                        iconSize: 30,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      GButton(
                        icon: Iconsax.camera,
                        iconSize: 30,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      GButton(
                        icon: Iconsax.messages,
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
          return UserHomeScreen();

        case 2:
          return UserHomeScreen();

        case 3:
          return UserHomeScreen();

        case 4:
          return UserHomeScreen();

        default:
          return UserHomeScreen();
      }
    } else {
      switch (index) {
        case 0:
          return UserHomeScreen();
        case 1:
          return UserHomeScreen();

        case 2:
          return UserHomeScreen();

        case 3:
          return UserHomeScreen();

        case 4:
          return UserHomeScreen();

        default:
          return UserHomeScreen();
      }
    }
  }
}
