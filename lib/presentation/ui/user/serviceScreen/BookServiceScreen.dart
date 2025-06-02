import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/model/PetModel.dart';
import '../../../../data/model/ServiceModel.dart';
import '../../pet/PetViewModel.dart';

class BookServiceScreen extends StatefulWidget {
  final ServiceModel service;

  const BookServiceScreen({required this.service, super.key});

  @override
  _BookServiceScreenState createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  PetModel? selectedPet;
  DateTime? selectedDateTime;

  @override
  Widget build(BuildContext context) {
    final petViewModel = Provider.of<PetViewModel>(context);
    final pets = petViewModel.pets;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Đặt lịch cho ${widget.service.title}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<PetModel>(
              hint: const Text('Chọn thú cưng'),
              value: selectedPet,
              onChanged: (PetModel? newValue) {
                setState(() {
                  selectedPet = newValue;
                });
              },
              items:
                  pets.map<DropdownMenuItem<PetModel>>((PetModel pet) {
                    return DropdownMenuItem<PetModel>(
                      value: pet,
                      child: Text(pet.name),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
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
              child: Text(
                selectedDateTime == null
                    ? 'Chọn thời gian'
                    : 'Thời gian: ${selectedDateTime.toString()}',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  selectedPet != null && selectedDateTime != null
                      ? () async {
                        final appointment = {
                          'service_id': widget.service.id,
                          'pet_id': selectedPet!.id,
                          'user_id':
                              Supabase.instance.client.auth.currentUser!.id,
                          'appointment_time':
                              selectedDateTime!.toIso8601String(),
                          'status': 'pending',
                        };
                        try {
                          await Supabase.instance.client
                              .from('appointments')
                              .insert(appointment);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đặt lịch thành công'),
                            ),
                          );
                          Navigator.pop(context);
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${error.toString()}')),
                          );
                        }
                      }
                      : null,
              child: const Text('Xác nhận đặt lịch'),
            ),
          ],
        ),
      ),
    );
  }
}
