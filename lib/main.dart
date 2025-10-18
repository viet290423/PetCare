import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:petcare/presentation/ui/auth/LoginScreen.dart';
import 'package:petcare/presentation/ui/doctor/AppointmentViewModel.dart';
import 'package:petcare/presentation/ui/doctor/homeScreen/DoctorHomeScreen.dart';
import 'package:petcare/presentation/ui/doctor/homeScreen/DoctorViewModel.dart';
import 'package:petcare/presentation/ui/main/MainScreen.dart';
import 'package:petcare/presentation/ui/pet/PetViewModel.dart';
import 'package:petcare/presentation/ui/user/homeScreen/UserHomeScreen.dart';
import 'package:petcare/presentation/ui/auth/AuthViewModel.dart';
import 'package:petcare/presentation/ui/user/homeScreen/UserHomeViewModel.dart';
import 'package:petcare/presentation/ui/user/serviceScreen/ServiceViewModel.dart';
import 'package:petcare/presentation/ui/disease/DiseaseViewModel.dart';
import 'package:petcare/presentation/provider/CommunityProvider.dart';
import 'package:petcare/presentation/provider/MessagingProvider.dart';
import 'package:petcare/services/noti_service.dart';
import 'package:petcare/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:petcare/presentation/provider/SettingsProvider.dart';
import 'package:petcare/di/injection_container.dart' as di;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/ui/auth/ResetPasswordScreen.dart';
import 'package:uni_links/uni_links.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  await Supabase.initialize(
    url: 'https://rreovfkkdgqsoxfqphrg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJyZW92ZmtrZGdxc294ZnFwaHJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3NzY0MzUsImV4cCI6MjA2MjM1MjQzNX0.WyKpgn6XHC1PuZTju-LqDr_D7T1BWVt0r5KRkWDqnjs',
  );
  await di.init();
  final notificationService = NotificationService();
  await notificationService.initialize();
  NotiService().initNotification();

  print('Main: Requesting notification permissions...');
  final permissionGranted = await notificationService.requestPermissions();
  print('Main: Notification permission granted: $permissionGranted');

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
        ChangeNotifierProvider(create: (_) => di.sl<DoctorViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<AppointmentViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<CommunityProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<MessagingProvider>()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final lightScheme = ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light).copyWith(
            background: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          );
          final darkScheme = ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PetCare',
            themeMode: settings.themeMode,
            theme: ThemeData(
              colorScheme: lightScheme,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              colorScheme: darkScheme,
              scaffoldBackgroundColor: Color.fromRGBO(12, 12, 12, 0.5),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            locale: settings.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('vi'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasNavigated = false;
  StreamSubscription? _authSub;
  StreamSubscription? _linkSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).checkCurrentUser();
    });

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
          );
        });
      }
    });

    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Handle initial link when app is opened by recovery email
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        await _handleIncomingUri(initialUri);
      }
    } catch (_) {}

    // Handle links while app is running
    _linkSub = uriLinkStream.listen((uri) async {
      if (uri != null) {
        await _handleIncomingUri(uri);
      }
    }, onError: (_) {});
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    // Expect something like io.supabase.flutter://login-callback#...&type=recovery or query param
    final isRecovery =
        uri.queryParameters['type'] == 'recovery' || uri.fragment.contains('type=recovery');
    if (isRecovery) {
      try {
        await Supabase.instance.client.auth.exchangeCodeForSession(uri as String);
      } catch (_) {
        // ignore; if already exchanged or not needed, continue
      }
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
      );
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _linkSub?.cancel();
    super.dispose();
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

        if (viewModel.user != null && !_hasNavigated) {
          _hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => MainScreen(user: viewModel.user!),
              ),
              (route) => false,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.user == null) {
          _hasNavigated = false;
        }

        return const LoginScreen();
      },
    );
  }
}
