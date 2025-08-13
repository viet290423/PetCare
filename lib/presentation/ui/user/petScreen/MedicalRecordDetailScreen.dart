import 'package:flutter/material.dart';

import '../../../../data/model/MedicalRecordModel.dart';
import '../../../../data/model/PetModel.dart';

class MedicalRecordDetailScreen extends StatelessWidget {
  final MedicalRecordModel record;
  final PetModel pet;

  const MedicalRecordDetailScreen({super.key, required this.record, required this.pet});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(record.recordType);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chi tiết hồ sơ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(typeColor),
            const SizedBox(height: 12),
            _buildSection('Thông tin thú cưng', [
              _kv('Tên thú cưng', pet.name),
              _kv('Giống', pet.breed),
              _kv('Giới tính', pet.gender),
            ]),
            const SizedBox(height: 12),
            _buildSection('Thông tin hồ sơ', [
              _kv('Loại', _typeText(record.recordType)),
              _kv('Ngày khám', '${record.recordDate.day}/${record.recordDate.month}/${record.recordDate.year}'),
              _kv('Bác sĩ', record.doctorName ?? 'Không có'),
              _kv('Trạng thái', _statusText(record.status)),
              if (record.cost != null) _kv('Chi phí', '${record.cost!.toStringAsFixed(0)} VNĐ'),
              if (record.nextVisitDate != null) _kv('Ngày tái khám', record.nextVisitDate!),
            ]),
            if (record.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildTextBlock('Chẩn đoán & điều trị', record.description),
            ],
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildTextBlock('Ghi chú', record.notes!),
            ],
            if (record.medications != null && record.medications!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildChips('Thuốc', record.medications!),
            ],
            if (record.attachments != null && record.attachments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildAttachments(record.attachments!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color typeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 26, backgroundColor: typeColor.withOpacity(0.15), child: Icon(Icons.medical_services, color: typeColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(record.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_typeText(record.recordType), style: TextStyle(fontSize: 12, color: typeColor)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(record.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _statusText(record.status),
              style: TextStyle(color: _statusColor(record.status), fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...children,
      ]),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 120, child: Text(k, style: TextStyle(color: Colors.grey[600]))),
        Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _buildTextBlock(String title, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(text),
      ]),
    );
  }

  Widget _buildChips(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: items.map((e) => Chip(label: Text(e))).toList()),
      ]),
    );
  }

  Widget _buildAttachments(List<String> urls) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tệp đính kèm', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: urls.length,
          itemBuilder: (context, index) {
            final url = urls[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(url, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported))),
            );
          },
        ),
      ]),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'checkup':
        return Colors.blue;
      case 'vaccination':
        return Colors.green;
      case 'treatment':
        return Colors.orange;
      case 'surgery':
        return Colors.red;
      case 'test':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _typeText(String type) {
    switch (type) {
      case 'checkup':
        return 'Khám định kỳ';
      case 'vaccination':
        return 'Tiêm chủng';
      case 'treatment':
        return 'Điều trị';
      case 'surgery':
        return 'Phẫu thuật';
      case 'test':
        return 'Xét nghiệm';
      default:
        return type;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'completed':
        return 'Hoàn thành';
      case 'ongoing':
        return 'Đang thực hiện';
      case 'scheduled':
        return 'Đã lên lịch';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.blue;
      case 'scheduled':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}


