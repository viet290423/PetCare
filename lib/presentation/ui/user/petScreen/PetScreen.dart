import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../../data/model/ReminderModel.dart';
import '../../../../data/model/AppointmentModel.dart';
import '../../pet/AddPetScreen.dart';
import '../../pet/AddReminderScreen.dart';
import '../homeScreen/UserHomeViewModel.dart';
import '../../pet/PetViewModel.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen>
    with SingleTickerProviderStateMixin {
  bool _isInitialized = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
      viewModel.clearCache();
      await viewModel.fetchPets(forceRefresh: true);
      if (viewModel.pets.isNotEmpty && mounted) {
        final petId = viewModel.pets.first.id;
        viewModel.selectedPetId = petId;
        await viewModel.fetchReminders(petId, forceRefresh: true);
        await viewModel.fetchAppointments(petId, forceRefresh: true);
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
      if (viewModel.selectedPetId != null) {
        viewModel.clearCache(); // Xóa cache
        viewModel.fetchPets(forceRefresh: true);
        viewModel.fetchReminders(viewModel.selectedPetId!, forceRefresh: true);
        viewModel.fetchAppointments(
          viewModel.selectedPetId!,
          forceRefresh: true,
        );
      }
    }
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
              viewModel.selectedPetId != null
                  ? 'Hôm nay ${pets.firstWhere((p) => p.id == viewModel.selectedPetId).name} thế nào?'
                  : 'Hãy chọn thú cưng để xem nhắc nhở',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
                    height: 96,
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
                                    await viewModel.fetchPets(
                                      forceRefresh: true,
                                    );
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
                        final isSelected = pet.id == viewModel.selectedPetId;
                        return GestureDetector(
                          onTap: () async {
                            viewModel.selectedPetId = pet.id;
                            await viewModel.fetchReminders(pet.id);
                            await viewModel.fetchAppointments(pet.id);
                            setState(() {});
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
                  Container(
                    child: TabBar(
                      controller: _tabController,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: Colors.green[700]!,
                          width: 2,
                        ),
                      ),
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(text: 'TO-DOS'),
                        Tab(text: 'TIPS'),
                        Tab(text: 'RECORDS'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        viewModel.selectedPetId == null
                            ? const Center(
                              child: Text('Hãy chọn thú cưng để xem nhắc nhở'),
                            )
                            : Consumer<UserHomeViewModel>(
                              builder: (context, viewModel, _) {
                                final reminders = viewModel.reminders;
                                final appointments = viewModel.appointments;

                                return SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
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
                                                  viewModel.selectedPetId !=
                                                      null) {
                                                await viewModel.fetchReminders(
                                                  viewModel.selectedPetId!,
                                                  forceRefresh: true,
                                                );
                                                await viewModel
                                                    .fetchAppointments(
                                                      viewModel.selectedPetId!,
                                                      forceRefresh: true,
                                                    );
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
                                              (r) => Slidable(
                                                endActionPane: ActionPane(
                                                  motion: const ScrollMotion(),
                                                  children: [
                                                    SlidableAction(
                                                      onPressed: (context) async {
                                                        final confirm = await showDialog<bool>(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: Text('Xác nhận xóa'),
                                                            content: Text('Bạn có chắc muốn xóa nhắc nhở này?'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => Navigator.of(context).pop(false),
                                                                child: Text('Hủy'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () => Navigator.of(context).pop(true),
                                                                child: Text('Xóa'),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                        if (confirm == true) {
                                                          try {
                                                            await viewModel.deleteReminder(r.id);
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Row(
                                                                  children: [
                                                                    Icon(Icons.check_circle, color: Colors.white),
                                                                    const SizedBox(width: 8),
                                                                    const Text('Xóa nhắc nhở thành công!'),
                                                                  ],
                                                                ),
                                                                backgroundColor: Colors.green,
                                                                behavior: SnackBarBehavior.floating,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),
                                                              ),
                                                            );
                                                          } catch (e) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                content: Row(
                                                                  children: [
                                                                    Icon(Icons.error_outline, color: Colors.white),
                                                                    const SizedBox(width: 8),
                                                                    Text('Lỗi khi xóa nhắc nhở: $e'),
                                                                  ],
                                                                ),
                                                                backgroundColor: Colors.red,
                                                                behavior: SnackBarBehavior.floating,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      backgroundColor: Colors.red,
                                                      foregroundColor: Colors.white,
                                                      icon: Icons.delete,
                                                      label: 'Delete',
                                                      borderRadius: BorderRadius.circular(20),
                                                      flex: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: Card(
                                                  color: Colors.white,
                                                  child: ListTile(
                                                    leading: const Icon(
                                                      CupertinoIcons.bell,
                                                      color: Colors.green,
                                                    ),
                                                    title: Text(
                                                      r.title,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Icon(
                                                          CupertinoIcons
                                                              .tag_solid,
                                                          color: Colors.green,
                                                          size: 12,
                                                        ),
                                                        Text(r.type),
                                                        const Icon(
                                                          CupertinoIcons
                                                              .calendar,
                                                          color: Colors.green,
                                                          size: 12,
                                                        ),
                                                        Text(
                                                          "${r.dateTime.day}/${r.dateTime.month}/${r.dateTime.year}",
                                                        ),
                                                        const Icon(
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
                                            ),
                                        if (reminders.length > 2)
                                          Center(
                                            child: TextButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
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
                                          ),
                                      ],
                                      const SizedBox(height: 20),
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
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
                                                  leading: const Icon(
                                                    CupertinoIcons.calendar,
                                                    color: Colors.green,
                                                  ),
                                                  title: Text(
                                                    a.serviceTitle != null
                                                        ? a.serviceTitle!
                                                        : 'Lịch hẹn #${a.id}',
                                                    style: const TextStyle(
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
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
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
                        // Nội dung cho Tips
                        Center(
                          child: Text(
                            'Tips Content',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        // Nội dung cho Records
                        Center(
                          child: Text(
                            'Records Content',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
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

  const _AllRemindersSheet({
    required this.reminders,
  });

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
                            const Icon(
                              CupertinoIcons.tag_solid,
                              color: Colors.green,
                              size: 12,
                            ),
                            Text(r.type),
                            const Icon(
                              CupertinoIcons.calendar,
                              color: Colors.green,
                              size: 12,
                            ),
                            Text(
                              "${r.dateTime.day}/${r.dateTime.month}/${r.dateTime.year}",
                            ),
                            const Icon(
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

  const _AllAppointmentsSheet({required this.appointments});

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
                        leading: const Icon(
                          CupertinoIcons.calendar,
                          color: Colors.green,
                        ),
                        title: Text(
                          a.serviceTitle != null
                              ? a.serviceTitle!
                              : 'Lịch hẹn #${a.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
