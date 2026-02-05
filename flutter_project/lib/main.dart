import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project/providers/theme_provider.dart';
import 'package:flutter_project/providers/user_provider.dart';
<<<<<<< HEAD
import 'package:flutter_project/utils/app_theme.dart';
import 'package:flutter_project/screens/main_screen.dart';
// import 'package:flutter_project/screens/login_screen_new.dart';
=======
import 'package:flutter_project/providers/worker_provider.dart';
import 'package:flutter_project/utils/app_theme.dart';
import 'package:flutter_project/screens/onboarding_screen.dart';
import 'package:flutter_project/screens/login_screen.dart';
>>>>>>> kajal
import 'package:flutter_project/screens/register_screen.dart';
import 'package:flutter_project/screens/edit_profile_screen.dart';
import 'package:flutter_project/screens/reviews_screen.dart';
import 'package:flutter_project/screens/all_services_screen.dart';
<<<<<<< HEAD
import 'package:flutter_project/screens/login_screen.dart';

void main() {
=======

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
>>>>>>> kajal
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
<<<<<<< HEAD
=======
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
>>>>>>> kajal
      ],
      child: const HomeServicesApp(),
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
<<<<<<< HEAD
          home: const MainScreen(),
=======
          home: const AppInitializer(),
>>>>>>> kajal
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/edit-profile': (context) => const EditProfileScreen(),
            '/reviews': (context) => const ReviewsScreen(),
            '/all-services': (context) => const AllServicesScreen(),
          },
        );
      },
    );
  }
}
<<<<<<< HEAD
=======

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Always start on onboarding screen - no session persistence
    return const OnboardingScreen();
  }
}
>>>>>>> kajal
