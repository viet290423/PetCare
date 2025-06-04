import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/model/ReminderModel.dart';
import '../../../../data/model/AppointmentModel.dart'; // Thêm import
import '../../pet/AddPetScreen.dart';
import '../../pet/AddReminderScreen.dart';
import '../homeScreen/UserHomeViewModel.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
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
        await viewModel.fetchAppointments(selectedPetId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserHomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }

        if (viewModel.error != null) {
          return Center(child: Text('Lỗi: ${viewModel.error}'));
        }

        final pets = viewModel.pets;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            forceMaterialTransparency: true,
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              selectedPetId != null
                  ? 'Hôm nay ${pets.firstWhere((p) => p.id == selectedPetId).name} thế nào?'
                  : 'Hãy chọn thú cưng để xem nhắc nhở',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                    child: const Icon(
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
                        final isSelected = pet.id == selectedPetId;
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectedPetId = pet.id;
                            });
                            await viewModel.fetchReminders(pet.id);
                            await viewModel.fetchAppointments(pet.id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.green.shade100
                                        : Colors.transparent,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.green.shade300
                                          : Colors.grey.shade300,
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
                  Expanded(
                    child:
                        selectedPetId == null
                            ? const Center(
                              child: Text('Hãy chọn thú cưng để xem nhắc nhở'),
                            )
                            : Consumer<UserHomeViewModel>(
                              builder: (context, viewModel, _) {
                                final reminders = viewModel.reminders;
                                final appointments =
                                    viewModel
                                        .appointments; // Lấy danh sách lịch hẹn

                                return SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Phần Nhắc nhở
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: const [
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
                                            onPressed: () async {
                                              final result =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              AddReminderScreen(
                                                                pets:
                                                                    viewModel
                                                                        .pets,
                                                              ),
                                                    ),
                                                  );
                                              if (result == true &&
                                                  selectedPetId != null) {
                                                await viewModel.fetchReminders(
                                                  selectedPetId!,
                                                );
                                                await viewModel
                                                    .fetchAppointments(
                                                      selectedPetId!,
                                                    ); // Cập nhật lại lịch hẹn
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      if (reminders.isEmpty)
                                        const Center(
                                          child: Text('Không có nhắc nhở nào.'),
                                        )
                                      else ...[
                                        ...reminders
                                            .take(2)
                                            .map(
                                              (r) => Card(
                                                color: Colors.white,
                                                child: ListTile(
                                                  leading: Icon(
                                                    CupertinoIcons.bell,
                                                    color: Colors.green,
                                                  ),
                                                  title: Text(
                                                    r.title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Icon(
                                                        CupertinoIcons
                                                            .tag_solid,
                                                        color: Colors.green,
                                                        size: 12,
                                                      ),
                                                      Text(r.type),
                                                      Icon(
                                                        CupertinoIcons.calendar,
                                                        color: Colors.green,
                                                        size: 12,
                                                      ),
                                                      Text(
                                                        "${r.dateTime.day}/${r.dateTime.month}/${r.dateTime.year}",
                                                      ),
                                                      Icon(
                                                        CupertinoIcons.repeat,
                                                        color: Colors.green,
                                                        size: 12,
                                                      ),
                                                      Text(r.repeatType),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        if (reminders.length > 2)
                                          TextButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                    ),
                                                builder:
                                                    (_) => _AllRemindersSheet(
                                                      reminders: reminders,
                                                    ),
                                              );
                                            },
                                            child: const Text(
                                              'Xem tất cả',
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                      ],
                                      const SizedBox(height: 20),

                                      // Phần Lịch hẹn
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(
                                                Icons.event_available,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "Lịch hẹn",
                                                style: TextStyle(
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      if (appointments.isEmpty)
                                        const Center(
                                          child: Text('Không có lịch hẹn nào.'),
                                        )
                                      else ...[
                                        ...appointments
                                            .take(2)
                                            .map(
                                              (a) => Card(
                                                color: Colors.white,
                                                child: ListTile(
                                                  leading: Icon(
                                                    CupertinoIcons.calendar,
                                                    color: Colors.green,
                                                  ),
                                                  title: Text(
                                                    a.serviceTitle != null
                                                        ? a.serviceTitle!
                                                        : 'Lịch hẹn #${a.id}',
                                                    // Hiển thị tên dịch vụ
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Thời gian: ${a.appointmentTime.toString().substring(0, 16)}',
                                                      ),
                                                      Text(
                                                        'Trạng thái: ${a.status}',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        if (appointments.length > 2)
                                          Center(
                                            child: TextButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                      ),
                                                  builder:
                                                      (_) =>
                                                          _AllAppointmentsSheet(
                                                            appointments:
                                                                appointments,
                                                          ),
                                                );
                                              },
                                              child: const Text(
                                                'Xem tất cả',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
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
        );
      },
    );
  }
}

class _AllRemindersSheet extends StatelessWidget {
  final List<ReminderModel> reminders;

  const _AllRemindersSheet({super.key, required this.reminders});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Tất cả lời nhắc',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final r = reminders[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          CupertinoIcons.bell,
                          color: Colors.green,
                        ),
                        title: Text(r.title),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              CupertinoIcons.tag_solid,
                              color: Colors.green,
                              size: 12,
                            ),
                            Text(r.type),
                            Icon(
                              CupertinoIcons.calendar,
                              color: Colors.green,
                              size: 12,
                            ),
                            Text(
                              "${r.dateTime.day}/${r.dateTime.month}/${r.dateTime.year}",
                            ),
                            Icon(
                              CupertinoIcons.repeat,
                              color: Colors.green,
                              size: 12,
                            ),
                            Text(r.repeatType),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AllAppointmentsSheet extends StatelessWidget {
  final List<AppointmentModel> appointments;

  const _AllAppointmentsSheet({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Tất cả lịch hẹn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final a = appointments[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          CupertinoIcons.calendar,
                          color: Colors.green,
                        ),
                        title: Text(
                          a.serviceTitle != null
                              ? a.serviceTitle!
                              : 'Lịch hẹn #${a.id}', // Hiển thị tên dịch vụ
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thời gian: ${a.appointmentTime.toString().substring(0, 16)}',
                            ),
                            Text('Trạng thái: ${a.status}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
