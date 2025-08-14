import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/model/MedicalRecordModel.dart';
import '../../../../data/model/PetModel.dart';
import '../homeScreen/UserHomeViewModel.dart';
import 'MedicalRecordDetailScreen.dart';

class MedicalRecordsListScreen extends StatefulWidget {
  final PetModel pet;

  const MedicalRecordsListScreen({super.key, required this.pet});

  @override
  State<MedicalRecordsListScreen> createState() => _MedicalRecordsListScreenState();
}

class _MedicalRecordsListScreenState extends State<MedicalRecordsListScreen> {
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

  final List<Map<String, String>> _defaultStatuses = const [
    {'value': 'all', 'label': 'Tất cả'},
    {'value': 'completed', 'label': 'Hoàn thành'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<UserHomeViewModel>();
      vm.fetchMedicalRecords(widget.pet.id, forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserHomeViewModel>(
      builder: (context, vm, _) {
        final allRecords = vm.medicalRecords;
        final filtered = _applyFilters(allRecords);

        // Xây danh sách trạng thái dựa trên dữ liệu thực tế (chỉ hiện những trạng thái có trong records)
        final statusesOptions = _buildStatusesOptions(allRecords);

        // Nếu lựa chọn hiện tại không còn hợp lệ, reset về 'all'
        if (!statusesOptions.any((e) => e['value'] == _selectedStatus)) {
          _selectedStatus = 'all';
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: Text('Hồ sơ của ${widget.pet.name}'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
          ),
          body: Column(
            children: [
              _buildSectionHeader(),
              const SizedBox(height: 8),
              _buildStatsRow(allRecords),
              const SizedBox(height: 8),
              _buildFilters(statusesOptions),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => vm.fetchMedicalRecords(widget.pet.id, forceRefresh: true),
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final record = filtered[index];
                                return _buildRecordTile(record);
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
    child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.insert_chart_outlined, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Hồ sơ y tế',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<MedicalRecordModel> records) {
    int completed = 0, ongoing = 0, scheduled = 0;
    for (final r in records) {
      switch (r.status) {
        case 'completed':
          completed++;
          break;
        case 'ongoing':
          ongoing++;
          break;
        case 'scheduled':
          scheduled++;
          break;
      }
    }

    Widget chip(Color color, IconData icon, String label, int value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          chip(Colors.green, Icons.check_circle, 'Hoàn thành', completed),
          const SizedBox(width: 8),
          chip(Colors.blue, Icons.autorenew, 'Đang thực hiện', ongoing),
          const SizedBox(width: 8),
          chip(Colors.orange, Icons.event, 'Đã lên lịch', scheduled),
        ],
      ),
    );
  }

  List<MedicalRecordModel> _applyFilters(List<MedicalRecordModel> input) {
    var result = List<MedicalRecordModel>.from(input);

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

    result.sort((a, b) => b.recordDate.compareTo(a.recordDate));
    return result;
  }

  List<Map<String, String>> _buildStatusesOptions(List<MedicalRecordModel> records) {
    final hasOngoing = records.any((r) => r.status == 'ongoing');
    final hasScheduled = records.any((r) => r.status == 'scheduled');
    final hasCancelled = records.any((r) => r.status == 'cancelled');

    final options = <Map<String, String>>[..._defaultStatuses];
    if (hasOngoing) {
      options.add({'value': 'ongoing', 'label': 'Đang thực hiện'});
    }
    if (hasScheduled) {
      options.add({'value': 'scheduled', 'label': 'Đã lên lịch'});
    }
    if (hasCancelled) {
      options.add({'value': 'cancelled', 'label': 'Đã hủy'});
    }

    return options;
  }

  Widget _buildFilters(List<Map<String, String>> statusesOptions) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 380;

        InputDecoration _inputDecoration({required String hint, required IconData icon}) => InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            );

        InputDecoration _dropdownDecoration(IconData icon) => InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              prefixIcon: Icon(icon, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 1.4)),
            );

        final typeDropdown = DropdownButtonFormField<String>(
          value: _selectedType,
          isDense: true,
          isExpanded: true,
          decoration: _dropdownDecoration(Icons.category_outlined),
          icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface, size: 22),
          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
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
              child: Row(
                children: [
                  SizedBox(width: 18, child: Icon(icon, size: 18, color: color)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
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
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                    Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            }).toList();
          },
          onChanged: (v) => setState(() => _selectedType = v ?? 'all'),
        );

        final statusDropdown = DropdownButtonFormField<String>(
          value: _selectedStatus,
          isDense: true,
          isExpanded: true,
          decoration: _dropdownDecoration(Icons.flag_outlined),
          icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface, size: 22),
          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
          dropdownColor: Theme.of(context).colorScheme.surface,
          menuMaxHeight: 320,
          borderRadius: BorderRadius.circular(12),
          items: statusesOptions.map((e) {
            final value = e['value']!;
            final label = e['label']!;
            final color = value == 'all' ? Colors.grey : _statusColor(value);
            final icon = _statusIcon(value);
            return DropdownMenuItem<String>(
              value: value,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(width: 18, child: Icon(icon, size: 18, color: color)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) {
            return statusesOptions.map((e) {
              final value = e['value']!;
              final label = e['label']!;
              final color = value == 'all' ? Colors.grey : _statusColor(value);
              final icon = _statusIcon(value);
              return Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                    Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            }).toList();
          },
          onChanged: (v) => setState(() => _selectedStatus = v ?? 'all'),
        );

        final searchField = TextField(
          decoration: _inputDecoration(hint: 'Tìm theo tiêu đề, mô tả...', icon: Icons.search),
          onChanged: (v) => setState(() => _searchQuery = v),
        );

        return Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surface,
          child: isCompact
              ? Column(
                  children: [
                    searchField,
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: typeDropdown),
                        const SizedBox(width: 8),
                        Expanded(child: statusDropdown),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 4, child: searchField),
                    const SizedBox(width: 8),
                    Expanded(flex: 3, child: typeDropdown),
                    const SizedBox(width: 8),
                    Expanded(flex: 3, child: statusDropdown),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_information, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('Chưa có hồ sơ phù hợp', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRecordTile(MedicalRecordModel record) {
    final color = _typeColor(record.recordType);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicalRecordDetailScreen(record: record, pet: widget.pet),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.medical_services, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(record.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.category, size: 14, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(_typeText(record.recordType), style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    const SizedBox(width: 10),
                    Icon(Icons.calendar_today, size: 14, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text('${record.recordDate.day}/${record.recordDate.month}/${record.recordDate.year}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    if (record.doctorName != null) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.person, size: 14, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Flexible(child: Text(record.doctorName!, style: TextStyle(fontSize: 12, color: Colors.grey[700]), overflow: TextOverflow.ellipsis)),
                    ],
                  ]),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _statusColor(record.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(_statusText(record.status), style: TextStyle(fontSize: 10, color: _statusColor(record.status), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
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

  IconData _statusIcon(String value) {
    switch (value) {
      case 'completed':
        return Icons.check_circle;
      case 'ongoing':
        return Icons.autorenew;
      case 'scheduled':
        return Icons.event;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.flag;
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
}


