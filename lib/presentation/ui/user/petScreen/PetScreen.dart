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
          return Center(child: Text('Lỗi: [38;5;9m${viewModel.error}[0m'));
        }

        final pets = viewModel.pets;
        final selectedPet =
            pets.isNotEmpty
                ? pets.firstWhere(
                  (p) => p.id == viewModel.selectedPetId,
                  orElse: () => pets.first,
                )
                : null;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            forceMaterialTransparency: true,
            elevation: 0,
            backgroundColor: Colors.white,
            title: Row(
              children: [
                if (selectedPet != null)
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(selectedPet.imageUrl),
                  ),
                if (selectedPet != null) const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedPet != null
                        ? 'Hôm nay ${selectedPet.name} thế nào?'
                        : 'Hãy chọn thú cưng để xem nhắc nhở',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 0.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh chọn thú cưng dạng card trượt ngang
                  SizedBox(
                    height: 150,
                    child:
                        pets.isEmpty
                            ? Center(child: Text('Chưa có thú cưng nào.'))
                            : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: pets.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final pet = pets[index];
                                final isSelected =
                                    pet.id == viewModel.selectedPetId;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  child: GestureDetector(
                                    onTap: () async {
                                      viewModel.selectedPetId = pet.id;
                                      await viewModel.fetchReminders(pet.id);
                                      await viewModel.fetchAppointments(pet.id);
                                      setState(() {});
                                    },
                                    child: Material(
                                      elevation: isSelected ? 8 : 2,
                                      borderRadius: BorderRadius.circular(24),
                                      color:
                                          isSelected
                                              ? Colors.green.shade50
                                              : Colors.white,
                                      child: Container(
                                        width: 110,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? Colors.green
                                                    : Colors.grey.shade200,
                                            width: isSelected ? 2.5 : 1.2,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 36,
                                              backgroundImage: NetworkImage(
                                                pet.imageUrl,
                                              ),
                                              backgroundColor: Colors.grey[200],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              pet.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color:
                                                    isSelected
                                                        ? Colors.green[800]
                                                        : Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                  const SizedBox(height: 18),
                  // TabBar đơn giản, underline bo tròn
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TabBar(
                      controller: _tabController,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: Colors.green[700]!,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        insets: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      labelColor: Colors.green[800],
                      unselectedLabelColor: Colors.grey[500],
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                      tabs: const [
                        Tab(text: 'TO-DOS'),
                        Tab(text: 'TIPS'),
                        Tab(text: 'RECORDS'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                child: const Icon(
                                                  Icons.calendar_month_outlined,
                                                  color: Colors.green,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Text(
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
                                              Icons.add_circle,
                                              color: Colors.green,
                                              size: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      if (reminders.isEmpty)
                                        Center(
                                          child: Text(
                                            'Không có nhắc nhở nào.',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        )
                                      else ...[
                                        ...reminders
                                            .take(2)
                                            .map(
                                              (r) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 10,
                                                ),
                                                child: Slidable(
                                                  endActionPane: ActionPane(
                                                    motion:
                                                        const ScrollMotion(),
                                                    children: [
                                                      SlidableAction(
                                                        onPressed: (
                                                          context,
                                                        ) async {
                                                          final confirm = await showDialog<
                                                            bool
                                                          >(
                                                            context: context,
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => AlertDialog(
                                                                  title: const Text(
                                                                    'Xác nhận xóa',
                                                                  ),
                                                                  content:
                                                                      const Text(
                                                                        'Bạn có chắc muốn xóa nhắc nhở này?',
                                                                      ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () => Navigator.of(
                                                                            context,
                                                                          ).pop(
                                                                            false,
                                                                          ),
                                                                      child:
                                                                          const Text(
                                                                            'Hủy',
                                                                          ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () => Navigator.of(
                                                                            context,
                                                                          ).pop(
                                                                            true,
                                                                          ),
                                                                      child:
                                                                          const Text(
                                                                            'Xóa',
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                          );
                                                          if (confirm == true) {
                                                            try {
                                                              await viewModel
                                                                  .deleteReminder(
                                                                    r.id,
                                                                  );
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .check_circle,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      const Text(
                                                                        'Xóa nhắc nhở thành công!',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                  ),
                                                                ),
                                                              );
                                                            } catch (e) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .error_outline,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        'Lỗi khi xóa nhắc nhở: $e',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        icon: Icons.delete,
                                                        label: 'Delete',
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                        flex: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Card(
                                                    elevation: 4,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            18,
                                                          ),
                                                    ),
                                                    color: Colors.white,
                                                    child: ListTile(
                                                      leading: Container(
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors
                                                                  .green
                                                                  .shade100,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              6,
                                                            ),
                                                        child: const Icon(
                                                          CupertinoIcons.bell,
                                                          color: Colors.green,
                                                          size: 28,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        r.title,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      subtitle: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4.0,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              CupertinoIcons
                                                                  .tag_solid,
                                                              color:
                                                                  Colors.green,
                                                              size: 14,
                                                            ),
                                                            const SizedBox(
                                                              width: 1,
                                                            ),
                                                            Text(
                                                              r.type,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            const Icon(
                                                              CupertinoIcons
                                                                  .calendar,
                                                              color:
                                                                  Colors.green,
                                                              size: 14,
                                                            ),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              "${r.dateTime.day}/${r.dateTime.month}/${r.dateTime.year}",
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            const Icon(
                                                              CupertinoIcons
                                                                  .repeat,
                                                              color:
                                                                  Colors.green,
                                                              size: 14,
                                                            ),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              r.repeatType,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
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
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                child: const Icon(
                                                  Icons.event_available,
                                                  color: Colors.green,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Text(
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
                                        Center(
                                          child: Text(
                                            'Không có lịch hẹn nào.',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        )
                                      else ...[
                                        ...appointments
                                            .take(2)
                                            .map(
                                              (a) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 10,
                                                ),
                                                child: Card(
                                                  elevation: 4,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                  ),
                                                  color: Colors.white,
                                                  child: ListTile(
                                                    leading: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors
                                                                .green
                                                                .shade100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      child: const Icon(
                                                        CupertinoIcons.calendar,
                                                        color: Colors.green,
                                                        size: 28,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      a.serviceTitle != null
                                                          ? a.serviceTitle!
                                                          : 'Lịch hẹn #${a.id}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    subtitle: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 4.0,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Thời gian: ${a.appointmentTime.toString().substring(0, 16)}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 13,
                                                                ),
                                                          ),
                                                          Text(
                                                            'Trạng thái: ${a.status}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 13,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
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
                                                  fontWeight: FontWeight.bold,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.green[400],
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Tips chăm sóc thú cưng sẽ xuất hiện ở đây!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        // Nội dung cho Records
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insert_chart_outlined,
                                color: Colors.green[400],
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Lịch sử & hồ sơ thú cưng sẽ xuất hiện ở đây!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
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

  const _AllRemindersSheet({required this.reminders});

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
