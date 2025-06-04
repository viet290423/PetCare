import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:petcare/presentation/ui/auth/LoginScreen.dart';
import 'package:petcare/presentation/ui/doctor/DoctorHomeScreen.dart';
import 'package:petcare/presentation/ui/main/MainScreen.dart';
import 'package:petcare/presentation/ui/pet/PetViewModel.dart';
import 'package:petcare/presentation/ui/user/homeScreen/UserHomeScreen.dart';
import 'package:petcare/presentation/ui/auth/AuthViewModel.dart';
import 'package:petcare/presentation/ui/user/homeScreen/UserHomeViewModel.dart';
import 'package:petcare/presentation/ui/user/serviceScreen/ServiceViewModel.dart';
import 'package:petcare/presentation/ui/disease/DiseaseViewModel.dart';
import 'package:provider/provider.dart';
import 'package:petcare/di/injection_container.dart' as di;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://rreovfkkdgqsoxfqphrg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJyZW92ZmtrZGdxc294ZnFwaHJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3NzY0MzUsImV4cCI6MjA2MjM1MjQzNX0.WyKpgn6XHC1PuZTju-LqDr_D7T1BWVt0r5KRkWDqnjs',
  );
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<UserHomeViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<PetViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<ServicesViewModel>()),
        ChangeNotifierProvider(create: (_) => DiseaseViewModel()),
      ],
      child: MaterialApp(title: 'PetCare', home: const AuthWrapper()),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).checkCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => MainScreen(user: viewModel.user!),
              ),
              (route) => false,
            );
          });
          return const SizedBox.shrink();
        }

        return const LoginScreen();
      },
    );
  }
}
