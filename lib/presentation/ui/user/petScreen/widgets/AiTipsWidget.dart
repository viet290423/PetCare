import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/model/PetTipsModel.dart';
import '../../homeScreen/UserHomeViewModel.dart';

class AiTipsWidget extends StatelessWidget {
  const AiTipsWidget({super.key});

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
          // Header với nút refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.purple,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "AI Tips chăm sóc",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  viewModel.refreshAiTips();
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.green,
                  size: 24,
                ),
                tooltip: 'Làm mới tips',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Tips content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade50,
                  Colors.blue.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.purple.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
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
                      Icons.psychology,
                      color: Colors.purple[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Gợi ý từ AI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormattedTips(aiTips.tip),
              ],
            ),
          ),
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
