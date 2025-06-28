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
import '../../../../services/notification_service.dart';

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
        final selectedPet = pets.isNotEmpty
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
                    height: 160,
                    child: pets.isEmpty
                        ? Center(child: Text('Chưa có thú cưng nào.'))
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: pets.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 16),
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
                                    elevation: isSelected ? 4 : 2,
                                    borderRadius: BorderRadius.circular(24),
                                    color: isSelected
                                        ? Colors.green.shade50
                                        : Colors.white,
                                    child: Container(
                                      width: 110,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.grey.shade200,
                                          width: isSelected ? 2 : 1,
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
                                              color: isSelected
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
                                child: Text(
                                  'Hãy chọn thú cưng để xem nhắc nhở',
                                ),
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
                                                    color:
                                                        Colors.green.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  child: const Icon(
                                                    Icons
                                                        .calendar_month_outlined,
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
                                                        builder: (_) =>
                                                            AddReminderScreen(
                                                              pets: viewModel
                                                                  .pets,
                                                            ),
                                                      ),
                                                    );
                                                if (result == true &&
                                                    viewModel.selectedPetId !=
                                                        null) {
                                                  await viewModel
                                                      .fetchReminders(
                                                        viewModel
                                                            .selectedPetId!,
                                                        forceRefresh: true,
                                                      );
                                                  await viewModel
                                                      .fetchAppointments(
                                                        viewModel
                                                            .selectedPetId!,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 10,
                                                      ),
                                                  child: Slidable(
                                                    endActionPane: ActionPane(
                                                      motion:
                                                          const ScrollMotion(),
                                                      children: [
                                                        SlidableAction(
                                                          onPressed: (context) async {
                                                            final confirm = await showDialog<bool>(
                                                              context: context,
                                                              builder: (context) => AlertDialog(
                                                                title: const Text(
                                                                  'Xác nhận xóa',
                                                                ),
                                                                content: const Text(
                                                                  'Bạn có chắc muốn xóa nhắc nhở này?',
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(
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
                                                                    onPressed: () =>
                                                                        Navigator.of(
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
                                                            if (confirm ==
                                                                true) {
                                                              try {
                                                                // Xóa thông báo trước
                                                                final notificationService =
                                                                    NotificationService();
                                                                await notificationService
                                                                    .cancelNotification(
                                                                      r.id.hashCode,
                                                                    );
                                                                print(
                                                                  'PetScreen: Cancelled notification for reminder: ${r.id}',
                                                                );

                                                                // Sau đó xóa reminder từ database
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
                                                      elevation: 2,
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
                                                            color: Colors
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
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                                                color: Colors
                                                                    .green,
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
                                                                color: Colors
                                                                    .green,
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
                                                                color: Colors
                                                                    .green,
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
                                                            top:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                    ),
                                                    builder: (_) =>
                                                        _AllRemindersSheet(
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
                                                    color:
                                                        Colors.green.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 10,
                                                      ),
                                                  child: Card(
                                                    elevation: 2,
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
                                                          color: Colors
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
                                                          CupertinoIcons
                                                              .calendar,
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
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                            ),
                                                            if (a.doctorName !=
                                                                null)
                                                              Text(
                                                                'Bác sĩ: ${a.doctorName}',
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                              ),
                                                            Text(
                                                              'Trạng thái: ${a.status}',
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
                                                            top:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                    ),
                                                    builder: (_) =>
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
                        Consumer<UserHomeViewModel>(
                          builder: (context, viewModel, _) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.lightbulb_outline,
                                          color: Colors.green,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Tips chăm sóc",
                                        style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Tips categories
                                  SizedBox(
                                    height: 120,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        _buildTipCategory(
                                          icon: Icons.favorite,
                                          title: "Sức khỏe",
                                          color: Colors.red.shade100,
                                          iconColor: Colors.red,
                                        ),
                                        _buildTipCategory(
                                          icon: Icons.restaurant,
                                          title: "Dinh dưỡng",
                                          color: Colors.orange.shade100,
                                          iconColor: Colors.orange,
                                        ),
                                        _buildTipCategory(
                                          icon: Icons.fitness_center,
                                          title: "Vận động",
                                          color: Colors.blue.shade100,
                                          iconColor: Colors.blue,
                                        ),
                                        _buildTipCategory(
                                          icon: Icons.psychology,
                                          title: "Tâm lý",
                                          color: Colors.purple.shade100,
                                          iconColor: Colors.purple,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Featured tips
                                  const Text(
                                    "Tips nổi bật",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  _buildTipCard(
                                    title: "Chăm sóc răng miệng cho thú cưng",
                                    description:
                                        "Đánh răng thường xuyên giúp ngăn ngừa các bệnh về răng miệng và hơi thở thơm mát.",
                                    icon: Icons.brush,
                                    color: Colors.blue.shade50,
                                    iconColor: Colors.blue,
                                  ),

                                  _buildTipCard(
                                    title: "Tắm rửa đúng cách",
                                    description:
                                        "Tắm 2-3 lần/tháng với sữa tắm chuyên dụng, tránh để nước vào tai và mắt.",
                                    icon: Icons.shower,
                                    color: Colors.cyan.shade50,
                                    iconColor: Colors.cyan,
                                  ),

                                  _buildTipCard(
                                    title: "Chế độ ăn cân bằng",
                                    description:
                                        "Cung cấp đầy đủ protein, vitamin và khoáng chất theo độ tuổi và cân nặng.",
                                    icon: Icons.restaurant_menu,
                                    color: Colors.green.shade50,
                                    iconColor: Colors.green,
                                  ),

                                  _buildTipCard(
                                    title: "Vận động hàng ngày",
                                    description:
                                        "Dành 30-60 phút mỗi ngày để chơi đùa và tập thể dục cùng thú cưng.",
                                    icon: Icons.directions_run,
                                    color: Colors.orange.shade50,
                                    iconColor: Colors.orange,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Nội dung cho Records
                        Consumer<UserHomeViewModel>(
                          builder: (context, viewModel, _) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.insert_chart_outlined,
                                          color: Colors.green,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Hồ sơ & Lịch sử",
                                        style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Health summary cards
                                  const Text(
                                    "Tóm tắt sức khỏe",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildHealthCard(
                                          title: "Cân nặng",
                                          value: "5.2 kg",
                                          trend: "+0.3 kg",
                                          isPositive: true,
                                          icon: Icons.monitor_weight,
                                          color: Colors.blue.shade50,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildHealthCard(
                                          title: "Tuổi",
                                          value: "2 tuổi",
                                          trend: "Trưởng thành",
                                          isPositive: true,
                                          icon: Icons.cake,
                                          color: Colors.pink.shade50,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildHealthCard(
                                          title: "Tiêm chủng",
                                          value: "Đầy đủ",
                                          trend: "Cập nhật",
                                          isPositive: true,
                                          icon: Icons.vaccines,
                                          color: Colors.green.shade50,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildHealthCard(
                                          title: "Khám định kỳ",
                                          value: "3 tháng trước",
                                          trend: "Sắp đến hạn",
                                          isPositive: false,
                                          icon: Icons.medical_services,
                                          color: Colors.orange.shade50,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Medical history
                                  const Text(
                                    "Lịch sử y tế",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  _buildMedicalRecordCard(
                                    date: "15/12/2024",
                                    title: "Khám định kỳ",
                                    description:
                                        "Sức khỏe tốt, tiêm vaccine cúm",
                                    doctor: "BS. Nguyễn Văn A",
                                    status: "Hoàn thành",
                                    isCompleted: true,
                                  ),

                                  _buildMedicalRecordCard(
                                    date: "20/11/2024",
                                    title: "Tiêm vaccine",
                                    description: "Tiêm vaccine 5 trong 1",
                                    doctor: "BS. Trần Thị B",
                                    status: "Hoàn thành",
                                    isCompleted: true,
                                  ),

                                  _buildMedicalRecordCard(
                                    date: "05/10/2024",
                                    title: "Khám bệnh",
                                    description: "Điều trị viêm tai",
                                    doctor: "BS. Lê Văn C",
                                    status: "Đang điều trị",
                                    isCompleted: false,
                                  ),

                                  const SizedBox(height: 24),

                                  // Growth chart placeholder
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.show_chart,
                                              color: Colors.green[600],
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              "Biểu đồ tăng trưởng",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              "Biểu đồ sẽ hiển thị ở đây",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
                            if (a.doctorName != null)
                              Text('Bác sĩ: ${a.doctorName}'),
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

Widget _buildTipCategory({
  required IconData icon,
  required String title,
  required Color color,
  required Color iconColor,
}) {
  return Container(
    width: 100,
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildTipCard({
  required String title,
  required String description,
  required IconData icon,
  required Color color,
  required Color iconColor,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    ),
  );
}

Widget _buildHealthCard({
  required String title,
  required String value,
  required String trend,
  required bool isPositive,
  required IconData icon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green[600], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              trend,
              style: TextStyle(
                fontSize: 12,
                color: isPositive ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildMedicalRecordCard({
  required String date,
  required String title,
  required String description,
  required String doctor,
  required String status,
  required bool isCompleted,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.schedule,
                color: isCompleted ? Colors.green : Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    doctor,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    ),
  );
}
