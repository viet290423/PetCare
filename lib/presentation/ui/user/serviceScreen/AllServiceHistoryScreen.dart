import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/model/AppointmentModel.dart';
import '../../../../data/model/PetModel.dart';
import '../../user/homeScreen/UserHomeViewModel.dart';
import '../../../../l10n/app_localizations.dart';

class AllServiceHistoryScreen extends StatefulWidget {
  const AllServiceHistoryScreen({super.key});

  @override
  State<AllServiceHistoryScreen> createState() => _AllServiceHistoryScreenState();
}

class _AllServiceHistoryScreenState extends State<AllServiceHistoryScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;

  String? _selectedPetId; // null = tất cả
  String _selectedStatus = 'all';
  String _searchQuery = '';

  List<Map<String, String>> get _statusOptions {
    final hasPending = _appointments.any((a) => a.status == 'pending');
    final hasConfirmed = _appointments.any((a) => a.status == 'confirmed');
    final hasCompleted = _appointments.any((a) => a.status == 'completed');
    final hasCancelled = _appointments.any((a) => a.status == 'cancelled');

    final base = <Map<String, String>>[
      {'value': 'all', 'label': AppLocalizations.of(context)!.all},
    ];
    if (hasPending) base.add({'value': 'pending', 'label': AppLocalizations.of(context)!.pending});
    if (hasConfirmed) base.add({'value': 'confirmed', 'label': AppLocalizations.of(context)!.confirmed});
    if (hasCompleted) base.add({'value': 'completed', 'label': AppLocalizations.of(context)!.completed});
    if (hasCancelled) base.add({'value': 'cancelled', 'label': AppLocalizations.of(context)!.cancelled});
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
      await _loadAppointments();
    });
  }

  Future<void> _loadAppointments() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resp = await _client
          .from('appointments')
          .select('*, services(title)')
          .eq('user_id', userId)
          .order('appointment_time', ascending: false);

      _appointments = (resp as List).map((e) => AppointmentModel.fromJson(e)).toList();
    } catch (e) {
      _error = AppLocalizations.of(context)!.cannot_load_service_history(e.toString());
    } finally {
      _isLoading = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pets = context.watch<UserHomeViewModel>().pets;
    final filtered = _applyFilters(_appointments);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.service_history, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildPetSelector(pets),
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAppointments,
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
                                final appt = filtered[index];
                                final pet = pets.firstWhere((p) => p.id == appt.petId, orElse: () => pets.first);
                                return _buildAppointmentCard(appt, pet);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(child: Text(message, style: TextStyle(color: Colors.red[400])));
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.no_service_history, style: TextStyle(color: Colors.grey[600])),
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
        child: Row(children: [
          _petChip(label: AppLocalizations.of(context)!.all, selected: _selectedPetId == null, onTap: () => setState(() => _selectedPetId = null)),
          for (final pet in pets) ...[
            const SizedBox(width: 8),
            _petChip(
              label: pet.name,
              avatarUrl: pet.imageUrl,
              selected: _selectedPetId == pet.id,
              onTap: () => setState(() => _selectedPetId = pet.id),
            ),
          ],
        ]),
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
        child: Row(children: [
          if (avatarUrl != null) ...[
            CircleAvatar(radius: 12, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 8),
          ],
          Text(label, style: TextStyle(color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 380;

        final searchField = TextField(
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search_by_service_doctor,
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
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
            statusDropdown,
          ]);
        }
        return Row(children: [
          Expanded(flex: 7, child: searchField),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: statusDropdown),
        ]);
      }),
    );
  }

  List<AppointmentModel> _applyFilters(List<AppointmentModel> input) {
    var result = List<AppointmentModel>.from(input);
    if (_selectedPetId != null) {
      result = result.where((a) => a.petId == _selectedPetId).toList();
    }
    if (_selectedStatus != 'all') {
      result = result.where((a) => a.status == _selectedStatus).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((a) {
        final sTitle = a.serviceTitle ?? '';
        final dName = a.doctorName ?? '';
        return sTitle.toLowerCase().contains(q) || dName.toLowerCase().contains(q);
      }).toList();
    }
    return result..sort((a, b) => b.appointmentTime.compareTo(a.appointmentTime));
  }

  Widget _buildAppointmentCard(AppointmentModel appt, PetModel pet) {
    final color = _statusColor(appt.status);
    return Container(
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
              Text(appt.serviceTitle ?? AppLocalizations.of(context)!.pet_service, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.pets, size: 14, color: Colors.green[600]),
                const SizedBox(width: 4),
                Flexible(child: Text(pet.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
                const SizedBox(width: 10),
                Icon(Icons.person, size: 14, color: Colors.green[600]),
                const SizedBox(width: 4),
                Flexible(child: Text(appt.doctorName ?? AppLocalizations.of(context)!.doctor, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
                const SizedBox(width: 10),
                Icon(Icons.calendar_today, size: 14, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text('${appt.appointmentTime.day}/${appt.appointmentTime.month}/${appt.appointmentTime.year}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(_statusText(appt.status), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
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

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return AppLocalizations.of(context)!.pending;
      case 'confirmed':
        return AppLocalizations.of(context)!.confirmed;
      case 'completed':
        return AppLocalizations.of(context)!.completed;
      case 'cancelled':
        return AppLocalizations.of(context)!.cancelled;
      default:
        return status;
    }
  }
}


