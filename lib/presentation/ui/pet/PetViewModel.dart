import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:petcare/domain/usecase/pet/AddReminderUseCase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

import '../../../data/model/PetModel.dart';
import '../../../data/model/ReminderModel.dart';
import '../../../domain/usecase/pet/AddPetUseCase.dart';
import '../../../domain/usecase/pet/PetUseCase.dart';
import '../../../domain/usecase/pet/DeleteReminderUseCase.dart';

class PetViewModel extends ChangeNotifier {
  final PetUseCase petUseCase;
  final AddPetUseCase addPetUseCase;
  final AddReminderUseCase addReminderUseCase;
  final DeleteReminderUseCase deleteReminderUseCase;

  PetViewModel({
    required this.petUseCase,
    required this.addPetUseCase,
    required this.addReminderUseCase,
    required this.deleteReminderUseCase,
  });

  List<PetModel> pets = [];
  bool isLoading = false;
  String? error;

  final SupabaseClient client = Supabase.instance.client;

  Future<void> addPet(PetModel pet) async {
    final result = await addPetUseCase(pet);
    result.fold(
      (failure) {
        error = failure;
        notifyListeners();
      },
      (_) {
        error = null;
        notifyListeners();
      },
    );
  }

  Future<String?> uploadPetImage(File file) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final storagePath = 'uploads/$fileName';

      final bytes = await file.readAsBytes();
      final response = await client.storage
          .from('pet-images')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(upsert: false),
          );

      if (response.isEmpty) throw Exception('Không thể upload ảnh');

      final imageUrl = client.storage
          .from('pet-images')
          .getPublicUrl(storagePath);
      return imageUrl;
    } catch (e) {
      print('Lỗi khi upload ảnh: $e');
      return null;
    }
  }

  Future<void> addReminder(ReminderModel reminder) async {
    isLoading = true;
    notifyListeners();

    try {
      await addReminderUseCase(reminder);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
