import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:flutter_project/customer/providers/booking_provider.dart';
import 'package:flutter_project/customer/providers/service_provider.dart';
import 'package:flutter_project/customer/providers/wallet_provider.dart';
import 'package:flutter_project/customer/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
            '/edit-profile': (context) => const EditProfileScreen(),
            '/reviews': (context) => const ReviewsScreen(),
            '/all-services': (context) => const AllServicesScreen(),
          },
        );
      },
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Always start on onboarding screen - no session persistence
    return const OnboardingScreen();
  }
}
