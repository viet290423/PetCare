import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/model/PetModel.dart';
import '../homeScreen/UserHomeViewModel.dart';
import '../../pet/AddPetScreen.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.55, initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
      await viewModel.fetchPets(forceRefresh: true);
      if (viewModel.pets.isNotEmpty && viewModel.selectedPetId == null) {
        viewModel.selectedPetId = viewModel.pets.first.id;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserHomeViewModel>(
      builder: (context, viewModel, child) {
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
            title: const Text(
              'Thông tin thú cưng',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.green),
          ),
          body:
              pets.isEmpty
                  ? const Center(child: Text('Bạn chưa có thú cưng nào.'))
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thanh chọn thú cưng dạng carousel
                      SizedBox(
                        height: 180,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: pets.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                              viewModel.selectedPetId = pets[index].id;
                            });
                          },
                          itemBuilder: (context, index) {
                            final pet = pets[index];
                            final isSelected = index == _currentPage;
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double? value = 1.0;
                                if (_pageController.position.haveDimensions) {
                                  value =
                                      ((_pageController.page ?? _currentPage) -
                                              index)
                                          as double?;
                                  value = (1 - (value!.abs() * 0.25));
                                  value =
                                      ((1 - (value.abs() * 0.25)).clamp(
                                                0.8,
                                                1.0,
                                              )
                                              as num)
                                          .toDouble();
                                }
                                return Center(
                                  child: Opacity(
                                    opacity: isSelected ? 1.0 : 0.6,
                                    child: Transform.scale(
                                      scale: value,
                                      child: GestureDetector(
                                        onTap: () {
                                          _pageController.animateToPage(
                                            index,
                                            duration: const Duration(
                                              milliseconds: 350,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        child: Material(
                                          elevation: isSelected ? 12 : 2,
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                          color:
                                              isSelected
                                                  ? Colors.green.shade50
                                                  : Colors.white,
                                          child: Container(
                                            width: 140,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(28),
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
                                                  radius: 44,
                                                  backgroundImage: NetworkImage(
                                                    pet.imageUrl,
                                                  ),
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  pet.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color:
                                                        isSelected
                                                            ? Colors.green[800]
                                                            : Colors.black87,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (selectedPet != null)
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 48,
                                      backgroundImage: NetworkImage(
                                        selectedPet.imageUrl,
                                      ),
                                      backgroundColor: Colors.grey[200],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      selectedPet.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _petInfoRow(
                                      Icons.pets,
                                      'Loài',
                                      selectedPet.type,
                                    ),
                                    _petInfoRow(
                                      Icons.category,
                                      'Giống',
                                      selectedPet.breed,
                                    ),
                                    _petInfoRow(
                                      Icons.cake,
                                      'Ngày sinh',
                                      selectedPet.birthDate,
                                    ),
                                    _petInfoRow(
                                      Icons.male,
                                      'Giới tính',
                                      selectedPet.gender,
                                    ),
                                    _petInfoRow(
                                      Icons.monitor_weight,
                                      'Cân nặng',
                                      '${selectedPet.weight}',
                                    ),
                                    _petInfoRow(
                                      Icons.color_lens,
                                      'Màu lông',
                                      selectedPet.color,
                                    ),
                                    const SizedBox(height: 16),
                                    // Có thể thêm nút chỉnh sửa/xóa ở đây nếu muốn
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPetScreen()),
              );
              if (result == true) {
                final viewModel = Provider.of<UserHomeViewModel>(
                  context,
                  listen: false,
                );
                await viewModel.fetchPets(forceRefresh: true);
                setState(() {});
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
            tooltip: 'Thêm thú cưng',
          ),
        );
      },
    );
  }

  Widget _petInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
