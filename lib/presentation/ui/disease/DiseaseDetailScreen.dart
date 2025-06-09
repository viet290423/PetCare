import 'package:flutter/material.dart';

import '../../../data/model/DiseaseModel.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final DiseaseModel disease;

  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(disease.title),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(disease.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Severity indicator
                  _buildSeverityIndicator(),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    disease.detailedDescription,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Symptoms
                  _buildSection('Triệu chứng', disease.symptoms, Icons.sick),
                  const SizedBox(height: 16),

                  // Causes
                  _buildSection('Nguyên nhân', disease.causes, Icons.warning),
                  const SizedBox(height: 16),

                  // Treatments
                  _buildSection(
                    'Cách điều trị',
                    disease.treatments,
                    Icons.medical_services,
                  ),
                  const SizedBox(height: 16),

                  // Preventions
                  _buildSection(
                    'Cách phòng ngừa',
                    disease.preventions,
                    Icons.shield,
                  ),
                  const SizedBox(height: 24),

                  // FAQs
                  const Text(
                    'Câu hỏi thường gặp',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...disease.faqs.map((faq) => _buildFAQItem(faq)),

                  const SizedBox(height: 24),

                  // Find nearby vet button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement find nearby vet functionality
                      },
                      icon: const Icon(Icons.location_on, color: Colors.white,),
                      label: const Text(
                        'Đặt lịch khám ngay',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityIndicator() {
    Color severityColor;
    String severityText;

    switch (disease.severity) {
      case 'high':
        severityColor = Colors.red;
        severityText = 'Nguy hiểm cao';
        break;
      case 'medium':
        severityColor = Colors.orange;
        severityText = 'Nguy hiểm trung bình';
        break;
      case 'low':
        severityColor = Colors.green;
        severityText = 'Nguy hiểm thấp';
        break;
      default:
        severityColor = Colors.grey;
        severityText = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: severityColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: severityColor, size: 16),
          const SizedBox(width: 8),
          Text(
            severityText,
            style: TextStyle(color: severityColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(item, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          faq,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Câu trả lời sẽ được cập nhật sớm...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
