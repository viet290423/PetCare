import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/model/PetTipsModel.dart';
import '../../homeScreen/UserHomeViewModel.dart';

class AiTipsWidget extends StatefulWidget {
  const AiTipsWidget({super.key});

  @override
  State<AiTipsWidget> createState() => _AiTipsWidgetState();
}

class _AiTipsWidgetState extends State<AiTipsWidget> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserHomeViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoadingTips) {
          return _buildLoadingState();
        }

        if (viewModel.error != null) {
          return _buildErrorState(context, viewModel.error!);
        }

        final aiTips = viewModel.currentAiTips;
        if (aiTips == null) {
          return _buildEmptyState(context);
        }

        return _buildTipsContent(context, aiTips, viewModel);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 16),
            Text(
              'AI đang phân tích thông tin thú cưng...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Không thể tải tips AI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
              viewModel.refreshAiTips();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 48,
            color: Colors.orange[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có tips AI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút bên dưới để AI tạo tips chăm sóc cá nhân hóa',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final viewModel = Provider.of<UserHomeViewModel>(context, listen: false);
              if (viewModel.selectedPetId != null) {
                viewModel.fetchAiTips(viewModel.selectedPetId!);
              }
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Tạo tips AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsContent(BuildContext context, PetTipsResponse aiTips, UserHomeViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // Header với nút refresh
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Row(
          //       children: [
          //         Container(
          //           decoration: BoxDecoration(
          //             color: Colors.purple.shade100,
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           padding: const EdgeInsets.all(6),
          //           child: const Icon(
          //             Icons.auto_awesome,
          //             color: Colors.purple,
          //             size: 22,
          //           ),
          //         ),
          //         const SizedBox(width: 10),
          //         const Text(
          //           "AI Tips chăm sóc",
          //           style: TextStyle(
          //             fontSize: 18,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ],
          //     ),
          //     IconButton(
          //       onPressed: () {
          //         viewModel.refreshAiTips();
          //       },
          //       icon: const Icon(
          //         Icons.refresh,
          //         color: Colors.green,
          //         size: 24,
          //       ),
          //       tooltip: 'Làm mới tips',
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 12),
          
          // Hiển thị danh mục và nội dung
          if (aiTips.categories != null && aiTips.categories!.hasAnyContent) ...[
            // Danh mục AI
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.category,
                    color: Colors.purple,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Danh mục Tips",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Danh mục categories
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (aiTips.categories!.health != null)
                    _buildSelectableCategory(
                      title: "Sức khỏe",
                      icon: Icons.favorite,
                      color: Colors.red.shade100,
                      iconColor: Colors.red,
                      isSelected: selectedCategory == 'health',
                      onTap: () => _selectCategory('health'),
                    ),
                  if (aiTips.categories!.nutrition != null)
                    _buildSelectableCategory(
                      title: "Dinh dưỡng",
                      icon: Icons.restaurant,
                      color: Colors.orange.shade100,
                      iconColor: Colors.orange,
                      isSelected: selectedCategory == 'nutrition',
                      onTap: () => _selectCategory('nutrition'),
                    ),
                  if (aiTips.categories!.care != null)
                    _buildSelectableCategory(
                      title: "Chăm sóc",
                      icon: Icons.spa,
                      color: Colors.green.shade100,
                      iconColor: Colors.green,
                      isSelected: selectedCategory == 'care',
                      onTap: () => _selectCategory('care'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nội dung tips theo danh mục được chọn
            if (selectedCategory != null)
              _buildSelectedCategoryContent(aiTips.categories!, selectedCategory!)
            else
              _buildCategoryHint(),
          ] else
            _buildFormattedTips(aiTips.tip),
        ],
      ),
    );
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  Widget _buildSelectableCategory({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.2) : color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? iconColor : iconColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? iconColor.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
              spreadRadius: isSelected ? 2 : 1,
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isSelected ? iconColor : iconColor.withOpacity(0.8), 
              size: 28
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
                color: isSelected ? iconColor : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCategoryContent(PetTipsCategories categories, String category) {
    List<PetTipCard>? cards;
    String? content;
    String title;
    IconData icon;
    Color color;
    Color iconColor;

    switch (category) {
      case 'health':
        cards = categories.healthCards;
        content = categories.health;
        title = 'Sức khỏe';
        icon = Icons.favorite;
        color = Colors.red.shade50;
        iconColor = Colors.red;
        break;
      case 'nutrition':
        cards = categories.nutritionCards;
        content = categories.nutrition;
        title = 'Dinh dưỡng';
        icon = Icons.restaurant;
        color = Colors.orange.shade50;
        iconColor = Colors.orange;
        break;
      case 'care':
        cards = categories.careCards;
        content = categories.care;
        title = 'Chăm sóc';
        icon = Icons.spa;
        color = Colors.green.shade50;
        iconColor = Colors.green;
        break;
      default:
        return const SizedBox.shrink();
    }

    // Nếu có cards, hiển thị dạng card
    if (cards != null && cards.isNotEmpty) {
      print('Displaying ${cards.length} cards for category $category');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...cards.map((card) => _buildTipCardFromModel(card)),
        ],
      );
    }

    // Fallback về hiển thị text nếu không có cards
    if (content == null) return const SizedBox.shrink();

    return _buildCategoryCard(
      title: title,
      content: content,
      icon: icon,
      color: color,
      iconColor: iconColor,
    );
  }

  Widget _buildTipCardFromModel(PetTipCard card) {
    final iconData = _getIconFromString(card.icon);
    final colorScheme = _getColorScheme(card.color);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme['background']!,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme['border']!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme['shadow']!,
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
              Icon(
                iconData,
                color: colorScheme['icon']!,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  card.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme['text']!,
                  ),
                ),
              ),
            ],
          ),
          if (card.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildFormattedParagraph(card.description),
          ],
        ],
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'warning':
        return Icons.warning;
      case 'medical_services':
        return Icons.medical_services;
      case 'vaccines':
        return Icons.vaccines;
      case 'favorite':
        return Icons.favorite;
      case 'restaurant':
        return Icons.restaurant;
      case 'water_drop':
        return Icons.water_drop;
      case 'medication':
        return Icons.medication;
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'shower':
        return Icons.shower;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'home':
        return Icons.home;
      case 'spa':
        return Icons.spa;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'monitor_heart':
        return Icons.monitor_heart;
      case 'food_bank':
        return Icons.food_bank;
      case 'no_food':
        return Icons.no_food;
      case 'scale':
        return Icons.scale;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'home_repair_service':
        return Icons.home_repair_service;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'psychology':
        return Icons.psychology;
      default:
        return Icons.lightbulb;
    }
  }

  Map<String, Color> _getColorScheme(String colorName) {
    switch (colorName) {
      case 'red':
        return {
          'background': Colors.red.shade50,
          'border': Colors.red.shade200,
          'icon': Colors.red,
          'text': Colors.red.shade800,
          'shadow': Colors.red.withOpacity(0.1),
        };
      case 'orange':
        return {
          'background': Colors.orange.shade50,
          'border': Colors.orange.shade200,
          'icon': Colors.orange,
          'text': Colors.orange.shade800,
          'shadow': Colors.orange.withOpacity(0.1),
        };
      case 'green':
        return {
          'background': Colors.green.shade50,
          'border': Colors.green.shade200,
          'icon': Colors.green,
          'text': Colors.green.shade800,
          'shadow': Colors.green.withOpacity(0.1),
        };
      case 'blue':
        return {
          'background': Colors.blue.shade50,
          'border': Colors.blue.shade200,
          'icon': Colors.blue,
          'text': Colors.blue.shade800,
          'shadow': Colors.blue.withOpacity(0.1),
        };
      case 'purple':
        return {
          'background': Colors.purple.shade50,
          'border': Colors.purple.shade200,
          'icon': Colors.purple,
          'text': Colors.purple.shade800,
          'shadow': Colors.purple.withOpacity(0.1),
        };
      case 'cyan':
        return {
          'background': Colors.cyan.shade50,
          'border': Colors.cyan.shade200,
          'icon': Colors.cyan,
          'text': Colors.cyan.shade800,
          'shadow': Colors.cyan.withOpacity(0.1),
        };
      case 'brown':
        return {
          'background': Colors.brown.shade50,
          'border': Colors.brown.shade200,
          'icon': Colors.brown,
          'text': Colors.brown.shade800,
          'shadow': Colors.brown.withOpacity(0.1),
        };
      default:
        return {
          'background': Colors.grey.shade50,
          'border': Colors.grey.shade200,
          'icon': Colors.grey,
          'text': Colors.grey.shade800,
          'shadow': Colors.grey.withOpacity(0.1),
        };
    }
  }

  Widget _buildCategoryHint() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.touch_app,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Chọn một danh mục để xem tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nhấn vào danh mục bên trên để xem gợi ý từ AI',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorizedTips(PetTipsCategories categories) {
    return Column(
      children: [
        // Sức khỏe
        if (categories.health != null)
          _buildCategoryCard(
            title: 'Sức khỏe',
            content: categories.health!,
            icon: Icons.favorite,
            color: Colors.red.shade50,
            iconColor: Colors.red,
          ),
        
        // Dinh dưỡng
        if (categories.nutrition != null)
          _buildCategoryCard(
            title: 'Dinh dưỡng',
            content: categories.nutrition!,
            icon: Icons.restaurant,
            color: Colors.orange.shade50,
            iconColor: Colors.orange,
          ),
        
        // Chăm sóc
        if (categories.care != null)
          _buildCategoryCard(
            title: 'Chăm sóc',
            content: categories.care!,
            icon: Icons.spa,
            color: Colors.green.shade50,
            iconColor: Colors.green,
          ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String content,
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
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
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
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFormattedParagraph(content),
        ],
      ),
    );
  }

  Widget _buildFormattedTips(String tips) {
    // Tách tips thành các đoạn dựa trên dấu xuống dòng
    final paragraphs = tips.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        // Kiểm tra xem có phải là tiêu đề không (có **text**)
        final isBold = paragraph.trim().startsWith('**') && paragraph.trim().endsWith('**');
        final cleanText = paragraph.replaceAll('**', '').trim();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: isBold
              ? Text(
                  cleanText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                )
              : _buildFormattedParagraph(cleanText),
        );
      }).toList(),
    );
  }

  Widget _buildFormattedParagraph(String text) {
    // Tách các dòng và xử lý bullet points
    final lines = text.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) return const SizedBox(height: 4);
        
        // Kiểm tra bullet points
        if (trimmedLine.startsWith('* ')) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    trimmedLine.substring(2),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            trimmedLine,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        );
      }).toList(),
    );
  }
}
