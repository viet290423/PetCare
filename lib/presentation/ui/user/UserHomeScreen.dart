import 'package:flutter/material.dart';
import 'package:petcare/presentation/ui/user/UserHomeViewModel.dart';
import 'package:provider/provider.dart';
import '../auth/AuthViewModel.dart';
import '../auth/LoginScreen.dart';
import '../pet/AddPetScreen.dart';
import '../pet/AddReminderScreen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String? selectedPetId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
      await viewModel.fetchPets();

      if (viewModel.pets.isNotEmpty && mounted) {
        setState(() {
          selectedPetId = viewModel.pets.first.id;
        });
        await viewModel.fetchReminders(selectedPetId!);
      }
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
                const Text("Trang chủ", style: TextStyle(fontWeight: FontWeight.bold)),
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
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Xin chào!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text(
                            selectedPetId != null
                                ? 'Hôm nay ${pets.firstWhere((p) => p.id == selectedPetId).name} thế nào?'
                                : 'Hãy chọn thú cưng để xem nhắc nhở',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const CircleAvatar(
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
                                      MaterialPageRoute(builder: (_) => const AddPetScreen()),
                                    );
                                    final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
                                    await viewModel.fetchPets();
                                  },
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(Icons.add, color: Colors.green),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(''),
                              ],
                            ),
                          );
                        }
                        final pet = pets[index];
                        final isSelected = pet.id == selectedPetId;
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectedPetId = pet.id;
                            });
                            await viewModel.fetchReminders(pet.id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green.shade100 : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? Colors.green.shade300: Colors.grey.shade300,
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
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.calendar_month_outlined, color: Colors.green),
                          SizedBox(width: 10),
                          Text("Nhắc nhở", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddReminderScreen(pets: viewModel.pets),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                      itemCount: viewModel.reminders.length,
                      itemBuilder: (context, index) {
                        final r = viewModel.reminders[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.check_circle_outline),
                            title: Text(r.title),
                            subtitle: Text(
                              "${r.type} • ${r.dateTime.day}/${r.dateTime.month}/${r.dateTime.year} • ${r.repeatType}",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
