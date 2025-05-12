import 'package:flutter/material.dart';
import 'package:petcare/presentation/ui/pet/PetViewModel.dart';
import 'package:petcare/presentation/ui/user/UserHomeViewModel.dart';
import 'package:provider/provider.dart';
import '../auth/AuthViewModel.dart';
import '../auth/LoginScreen.dart';
import '../pet/AddPetScreen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
      viewModel.fetchPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserHomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(child: Text('Lỗi: ${viewModel.error}'));
        }

        final pets = viewModel.pets;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Trang chủ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
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
            // backgroundColor: Colors.green,
          ),
          body: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [Colors.green.shade100, Colors.white],
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //   ),
            // ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Hôm nay Mèo Mun thế nào?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.pets, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 95,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pets.length + 1,
                        itemBuilder: (context, index) {
                          if (index == pets.length) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const AddPetScreen(),
                                        ),
                                      );
                                      final viewModel =
                                          Provider.of<UserHomeViewModel>(
                                            context,
                                            listen: false,
                                          );
                                      await viewModel.fetchPets();
                                    },
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(''),
                                ],
                              ),
                            );
                          }
                          final pet = pets[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                border: Border.all(
                                  color: Colors.green.shade300,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(pet.imageUrl),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(pet.name),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.green,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Nhắc nhở",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.add, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
