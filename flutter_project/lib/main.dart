import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_project/theme/theme_provider.dart';
import 'package:flutter_project/providers/user_provider.dart';
import 'package:flutter_project/providers/worker_provider.dart';
import 'package:flutter_project/theme/app_theme.dart';
import 'package:flutter_project/customer/screens/onboarding_screen.dart';
import 'package:flutter_project/auth/login_tab.dart';
import 'package:flutter_project/auth/register_tab.dart';
import 'package:flutter_project/customer/screens/edit_profile_screen.dart';
import 'package:flutter_project/customer/screens/reviews_screen.dart';
import 'package:flutter_project/customer/screens/all_services_screen.dart';
import 'package:flutter_project/customer/screens/main_screen.dart';
import 'package:flutter_project/worker/worker_home.dart';
import 'package:flutter_project/worker/providers/job_provider.dart';
import 'package:flutter_project/customer/providers/booking_provider.dart';
import 'package:flutter_project/customer/providers/service_provider.dart';
import 'package:flutter_project/customer/providers/wallet_provider.dart';
import 'package:flutter_project/customer/providers/language_provider.dart';
import 'package:flutter_project/customer/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase may not be configured in local dev yet.
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
      ],
      child: HomeServicesApp(),
    ),
  );
}

class HomeServicesApp extends StatelessWidget {
  const HomeServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Home Services',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.materialThemeMode,
          home: const AppInitializer(),
          routes: {
            '/login': (context) => LoginTab(
              roleColor: Theme.of(context).primaryColor,
              onSwitchToRegister: () {
                Navigator.pushNamed(context, '/register');
              },
            ),
            '/register': (context) => RegisterTab(
              roleColor: Theme.of(context).primaryColor,
              onSwitchToLogin: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            '/customer-home': (context) => const MainScreen(),
            '/worker-dashboard': (context) => const WorkerHome(),
            '/edit-profile': (context) => const EditProfileScreen(),
            '/reviews': (context) => const ReviewsScreen(),
            '/all-services': (context) => const AllServicesScreen(),
          },
        );
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<String> _initialRouteFuture;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initialRouteFuture = _resolveInitialRoute();
  }

  Future<String> _resolveInitialRoute() async {
    final userProvider = context.read<UserProvider>();
    final workerProvider = context.read<WorkerProvider>();

    await ApiService().initialize();

    await userProvider.initialize();
    if (userProvider.isLoggedIn) {
      await _registerFcmToken();
      return '/customer-home';
    }

    await workerProvider.initialize();
    if (workerProvider.isLoggedIn) {
      await _registerFcmToken();
      return '/worker-dashboard';
    }

    return 'onboarding';
  }

  Future<void> _registerFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await ApiService().saveFcmToken(token);
      }
    } catch (_) {
      // Ignore FCM setup/runtime errors in local development.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRouteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final route = snapshot.data ?? 'onboarding';
        if (route == 'onboarding') {
          return const OnboardingScreen();
        }

        if (!_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed(route);
          });
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
