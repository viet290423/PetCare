import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/model/MedicalRecordModel.dart';
import '../../../../data/model/PetModel.dart';
import '../homeScreen/UserHomeViewModel.dart';
import 'MedicalRecordDetailScreen.dart';

class AllMedicalRecordsScreen extends StatefulWidget {
  const AllMedicalRecordsScreen({super.key});

  @override
  State<AllMedicalRecordsScreen> createState() => _AllMedicalRecordsScreenState();
}

class _AllMedicalRecordsScreenState extends State<AllMedicalRecordsScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  List<MedicalRecordModel> _records = [];
  bool _isLoading = false;
  String? _error;

  String? _selectedPetId; // null = tất cả
  String _selectedType = 'all';
  String _selectedStatus = 'all';
  String _searchQuery = '';

  final List<Map<String, String>> _types = const [
    {'value': 'all', 'label': 'Tất cả loại'},
    {'value': 'checkup', 'label': 'Khám định kỳ'},
    {'value': 'vaccination', 'label': 'Tiêm chủng'},
    {'value': 'treatment', 'label': 'Điều trị'},
    {'value': 'surgery', 'label': 'Phẫu thuật'},
    {'value': 'test', 'label': 'Xét nghiệm'},
  ];

  List<Map<String, String>> get _statusOptions {
    // Chỉ hiển thị trạng thái có trong dữ liệu
    final hasCompleted = _records.any((r) => r.status == 'completed');
    final hasOngoing = _records.any((r) => r.status == 'ongoing');
    final hasScheduled = _records.any((r) => r.status == 'scheduled');
    final hasCancelled = _records.any((r) => r.status == 'cancelled');

    final base = <Map<String, String>>[
      {'value': 'all', 'label': 'Tất cả'},
    ];
    if (hasCompleted) base.add({'value': 'completed', 'label': 'Hoàn thành'});
    if (hasOngoing) base.add({'value': 'ongoing', 'label': 'Đang thực hiện'});
    if (hasScheduled) base.add({'value': 'scheduled', 'label': 'Đã lên lịch'});
    if (hasCancelled) base.add({'value': 'cancelled', 'label': 'Đã hủy'});
    if (!base.any((e) => e['value'] == _selectedStatus)) _selectedStatus = 'all';
    return base;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<UserHomeViewModel>();
      if (vm.pets.isEmpty) {
        await vm.fetchPets(forceRefresh: true);
      }
      await _loadAllRecords();
    });
  }

  Future<void> _loadAllRecords() async {
    final pets = context.read<UserHomeViewModel>().pets;
    if (pets.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final petIds = pets.map((p) => p.id).toList();
      final resp = await _client
          .from('medical_records')
          .select()
          .inFilter('pet_id', petIds)
          .order('record_date', ascending: false);

      _records = (resp as List).map((e) => MedicalRecordModel.fromJson(e)).toList();
    } catch (e) {
      _error = 'Không thể tải hồ sơ: $e';
    } finally {
      _isLoading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pets = context.watch<UserHomeViewModel>().pets;
    final filtered = _applyFilters(_records);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Hồ sơ y tế'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildPetSelector(pets),
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAllRecords,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError(_error!)
                      : filtered.isEmpty
                          ? _buildEmpty()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final record = filtered[index];
                                final pet = pets.firstWhere((p) => p.id == record.petId, orElse: () => pets.first);
                                return _buildRecordCard(record, pet);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Text(message, style: TextStyle(color: Colors.red[400])),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_information, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('Chưa có hồ sơ nào', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPetSelector(List<PetModel> pets) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _petChip(
              label: 'Tất cả',
              selected: _selectedPetId == null,
              onTap: () => setState(() => _selectedPetId = null),
            ),
            for (final pet in pets) ...[
              const SizedBox(width: 8),
              _petChip(
                label: pet.name,
                avatarUrl: pet.imageUrl,
                selected: _selectedPetId == pet.id,
                onTap: () => setState(() => _selectedPetId = pet.id),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _petChip({required String label, String? avatarUrl, required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.08) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            if (avatarUrl != null) ...[
              CircleAvatar(radius: 12, backgroundImage: NetworkImage(avatarUrl)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 380;
          final searchField = TextField(
            decoration: InputDecoration(
              hintText: 'Tìm theo tiêu đề, mô tả...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          );

          final typeDropdown = DropdownButtonFormField<String>(
            value: _selectedType,
            isDense: true,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              prefixIcon: const Icon(Icons.category_outlined, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.4)),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface, size: 22),
            dropdownColor: Theme.of(context).colorScheme.surface,
            menuMaxHeight: 320,
            borderRadius: BorderRadius.circular(12),
            items: _types.map((e) {
              final value = e['value']!;
              final label = e['label']!;
              final color = value == 'all' ? Colors.grey : _typeColor(value);
              final icon = _typeIcon(value);
              return DropdownMenuItem<String>(
                value: value,
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  SizedBox(width: 18, child: Icon(icon, size: 18, color: color)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                ]),
              );
            }).toList(),
            selectedItemBuilder: (context) {
              return _types.map((e) {
                final value = e['value']!;
                final label = e['label']!;
                final color = value == 'all' ? Colors.grey : _typeColor(value);
                final icon = _typeIcon(value);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                    Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                  ]),
                );
              }).toList();
            },
            onChanged: (v) => setState(() => _selectedType = v ?? 'all'),
          );

          final statusDropdown = DropdownButtonFormField<String>(
            value: _selectedStatus,
            isDense: true,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              prefixIcon: const Icon(Icons.flag_outlined, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.4)),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface, size: 22),
            dropdownColor: Theme.of(context).colorScheme.surface,
            menuMaxHeight: 320,
            borderRadius: BorderRadius.circular(12),
            items: _statusOptions.map((e) {
              final value = e['value']!;
              final label = e['label']!;
              final color = value == 'all' ? Colors.grey : _statusColor(value);
              final icon = _typeIcon(value);
              return DropdownMenuItem<String>(
                value: value,
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  SizedBox(width: 18, child: Icon(icon, size: 18, color: color)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                ]),
              );
            }).toList(),
            selectedItemBuilder: (context) {
              return _statusOptions.map((e) {
                final value = e['value']!;
                final label = e['label']!;
                final color = value == 'all' ? Colors.grey : _statusColor(value);
                final icon = _typeIcon(value);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                    Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                  ]),
                );
              }).toList();
            },
            onChanged: (v) => setState(() => _selectedStatus = v ?? 'all'),
          );

          if (isCompact) {
            return Column(children: [
              searchField,
              const SizedBox(height: 8),
              Row(children: [Expanded(child: typeDropdown), const SizedBox(width: 8), Expanded(child: statusDropdown)]),
            ]);
          }
          return Row(children: [
            Expanded(flex: 4, child: searchField),
            const SizedBox(width: 8),
            Expanded(flex: 3, child: typeDropdown),
            const SizedBox(width: 8),
            Expanded(flex: 3, child: statusDropdown),
          ]);
        },
      ),
    );
  }

  List<MedicalRecordModel> _applyFilters(List<MedicalRecordModel> input) {
    var result = List<MedicalRecordModel>.from(input);
    if (_selectedPetId != null) {
      result = result.where((r) => r.petId == _selectedPetId).toList();
    }
    if (_selectedType != 'all') {
      result = result.where((r) => r.recordType == _selectedType).toList();
    }
    if (_selectedStatus != 'all') {
      result = result.where((r) => r.status == _selectedStatus).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((r) => r.title.toLowerCase().contains(q) || r.description.toLowerCase().contains(q)).toList();
    }
    return result..sort((a, b) => b.recordDate.compareTo(a.recordDate));
  }

  Widget _buildRecordCard(MedicalRecordModel record, PetModel pet) {
    final color = _typeColor(record.recordType);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MedicalRecordDetailScreen(record: record, pet: pet)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ]),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 22, backgroundImage: NetworkImage(pet.imageUrl)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(record.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.pets, size: 14, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Flexible(child: Text(pet.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
                  const SizedBox(width: 10),
                  Icon(Icons.category, size: 14, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(_typeText(record.recordType), style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  const SizedBox(width: 10),
                  Icon(Icons.calendar_today, size: 14, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text('${record.recordDate.day}/${record.recordDate.month}/${record.recordDate.year}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _statusColor(record.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(_statusText(record.status), style: TextStyle(fontSize: 10, color: _statusColor(record.status), fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
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

  IconData _typeIcon(String value) {
    switch (value) {
      case 'checkup':
        return Icons.health_and_safety;
      case 'vaccination':
        return Icons.vaccines;
      case 'treatment':
        return Icons.healing;
      case 'surgery':
        return Icons.local_hospital;
      case 'test':
        return Icons.biotech;
      default:
        return Icons.category;
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


