import 'package:flutter/material.dart';
import 'package:petcare/presentation/ui/user/UserHomeViewModel.dart';
import 'package:provider/provider.dart';
import '../auth/AuthViewModel.dart';
import '../auth/LoginScreen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
    viewModel.fetchPets();
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
          body: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade100, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
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
                        // CircleAvatar(
                        //   backgroundColor: Colors.green,
                        //   child: Icon(Icons.pets, color: Colors.white),
                        // ),
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () async {
                            final authViewModel = context.read<AuthViewModel>();
                            await authViewModel.signOutUser();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Thú cưng của tôi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pets.length + 1,
                        itemBuilder: (context, index) {
                          if (index == pets.length) {
                            return GestureDetector(
                              onTap: () {
                                // Chuyển đến màn hình thêm thú cưng
                              },
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.add, color: Colors.green),
                              ),
                            );
                          }
                          final pet = pets[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(pet.imageUrl),
                                ),
                                const SizedBox(height: 5),
                                Text(pet.name),
                              ],
                            ),
                          );
                        },
                      ),
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
