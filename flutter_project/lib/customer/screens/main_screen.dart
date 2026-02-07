import 'package:flutter/material.dart';
import 'package:flutter_project/customer/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_project/customer/screens/home_screen.dart';
import 'package:flutter_project/customer/screens/account_screen.dart';
import 'package:flutter_project/customer/screens/history_screen.dart';
import 'package:flutter_project/customer/screens/wallet_screen.dart';
import 'package:flutter_project/customer/screens/menu_screen.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AccountScreen(),
    HistoryScreen(),
    WalletScreen(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}