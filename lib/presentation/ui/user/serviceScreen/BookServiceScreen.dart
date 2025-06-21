import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:petcare/presentation/ui/user/homeScreen/UserHomeViewModel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/model/PetModel.dart';
import '../../../../data/model/ServiceModel.dart';
import '../../../../data/model/AppointmentModel.dart';
import '../../pet/AddPetScreen.dart';
import 'ServiceViewModel.dart';

class BookServiceScreen extends StatefulWidget {
  final ServiceModel service;

  const BookServiceScreen({required this.service, super.key});

  @override
  _BookServiceScreenState createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen>
    with SingleTickerProviderStateMixin {
  PetModel? selectedPet;
  DateTime? selectedDateTime;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petViewModel = Provider.of<UserHomeViewModel>(
        context,
        listen: false,
      );
      petViewModel.fetchPets();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _bookAppointment() async {
    final servicesViewModel = Provider.of<ServicesViewModel>(
      context,
      listen: false,
    );
    final appointment = AppointmentModel(
      serviceId: widget.service.id,
      petId: selectedPet!.id,
      userId: Supabase.instance.client.auth.currentUser!.id,
      appointmentTime: selectedDateTime!,
      status: 'pending',
    );

    final result = await servicesViewModel.addAppointment(appointment);
    result.fold(
      (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Lỗi: $error'),
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
      },
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Đặt lịch thành công!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final petViewModel = Provider.of<UserHomeViewModel>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Đặt lịch dịch vụ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Header
                  Container(
                    width: double.infinity,
                    height: size.height * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            child: Image.network(
                              widget.service.imageUrl ??
                                  'https://via.placeholder.com/400x200',
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.3),
                              colorBlendMode: BlendMode.darken,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.service.title,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.attach_money,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.service.price != null
                                          ? NumberFormat('#,###', 'vi_VN')
                                              .format(widget.service.price)
                                              .replaceAll(',', '.')
                                          : 'Liên hệ để biết giá',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
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
                  const SizedBox(height: 24),

                  // Service Description
                  if (widget.service.description != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Mô tả dịch vụ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.service.description!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Pet Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pets, color: Colors.green, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Chọn thú cưng',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Consumer<UserHomeViewModel>(
                            builder: (context, petViewModel, child) {
                              if (petViewModel.error != null) {
                                return Center(
                                  child: Text(
                                    'Lỗi: ${petViewModel.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }
                              final pets = petViewModel.pets;
                              if (pets.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.green.shade100,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.pets,
                                        color: Colors.grey[400],
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Bạn chưa có thú cưng nào',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => const AddPetScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        label: const Text('Thêm thú cưng mới'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Container(
                                height: 200,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: pets.length,
                                  itemBuilder: (context, index) {
                                    final pet = pets[index];
                                    final isSelected =
                                        selectedPet?.id == pet.id;
                                    return Container(
                                      width: 160,
                                      margin: EdgeInsets.only(
                                        left: index == 0 ? 0 : 12,
                                        right: index == pets.length - 1 ? 0 : 0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedPet = pet;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                          decoration: BoxDecoration(
                                            gradient:
                                                isSelected
                                                    ? LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Colors.green.shade300,
                                                        Colors.green.shade500,
                                                      ],
                                                    )
                                                    : LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Colors.white,
                                                        Colors.grey.shade50,
                                                      ],
                                                    ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? Colors.green.shade300
                                                      : Colors.grey.shade200,
                                              width: isSelected ? 2.5 : 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    isSelected
                                                        ? Colors.green
                                                            .withOpacity(0.3)
                                                        : Colors.grey
                                                            .withOpacity(0.15),
                                                blurRadius:
                                                    isSelected ? 20 : 12,
                                                offset: const Offset(0, 6),
                                                spreadRadius:
                                                    isSelected ? 2 : 0,
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              // Background pattern for selected state
                                              if (isSelected)
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end:
                                                            Alignment
                                                                .bottomRight,
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(0.1),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                              // Main content
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Pet image with enhanced styling
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                isSelected
                                                                    ? Colors
                                                                        .green
                                                                        .withOpacity(
                                                                          0.4,
                                                                        )
                                                                    : Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                          0.2,
                                                                        ),
                                                            blurRadius: 15,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  8,
                                                                ),
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                        border: Border.all(
                                                          color:
                                                              isSelected
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .grey
                                                                      .shade300,
                                                          width:
                                                              isSelected
                                                                  ? 4
                                                                  : 3,
                                                        ),
                                                      ),
                                                      child: ClipOval(
                                                        child: Container(
                                                          width: 75,
                                                          height: 75,
                                                          decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            gradient: LinearGradient(
                                                              begin:
                                                                  Alignment
                                                                      .topLeft,
                                                              end:
                                                                  Alignment
                                                                      .bottomRight,
                                                              colors: [
                                                                Colors
                                                                    .grey
                                                                    .shade100,
                                                                Colors
                                                                    .grey
                                                                    .shade200,
                                                              ],
                                                            ),
                                                          ),
                                                          child: ClipOval(
                                                            child: Image.network(
                                                              pet.imageUrl ??
                                                                  'https://via.placeholder.com/90',
                                                              width: 75,
                                                              height: 75,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Container(
                                                                  width: 75,
                                                                  height: 75,
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade300,
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                  ),
                                                                  child: Icon(
                                                                    Icons.pets,
                                                                    size: 35,
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade600,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 16),

                                                    // Pet name with enhanced typography
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            isSelected
                                                                ? Colors.white
                                                                    .withOpacity(
                                                                      0.2,
                                                                    )
                                                                : Colors
                                                                    .grey
                                                                    .shade100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        pet.name,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              isSelected
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black87,
                                                          letterSpacing: 0.5,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),

                                                    // Pet breed with subtle styling
                                                    if (pet.breed != null) ...[
                                                      const SizedBox(height: 6),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              isSelected
                                                                  ? Colors.white
                                                                      .withOpacity(
                                                                        0.15,
                                                                      )
                                                                  : Colors
                                                                      .grey
                                                                      .shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                isSelected
                                                                    ? Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.3,
                                                                        )
                                                                    : Colors
                                                                        .grey
                                                                        .shade200,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          pet.breed!,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                isSelected
                                                                    ? Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.9,
                                                                        )
                                                                    : Colors
                                                                        .grey[600],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),

                                              // Selection indicator
                                              if (isSelected)
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.green
                                                              .withOpacity(0.3),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      color:
                                                          Colors.green.shade600,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // DateTime Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Chọn thời gian',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.green,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              final TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Colors.green,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setState(() {
                                  selectedDateTime = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ngày và giờ hẹn',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedDateTime == null
                                            ? 'Chọn ngày và giờ'
                                            : DateFormat(
                                              'EEEE, dd/MM/yyyy HH:mm',
                                              'vi_VN',
                                            ).format(selectedDateTime!),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              selectedDateTime == null
                                                  ? Colors.grey[600]
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Confirm Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            selectedPet != null && selectedDateTime != null
                                ? () async {
                                  await _bookAppointment();
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Xác nhận đặt lịch',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Full screen loading overlay
          if (petViewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đang tải...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
