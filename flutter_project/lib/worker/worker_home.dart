import 'package:flutter/material.dart';
import 'screens/worker_money_screen.dart';
import 'screens/account_screen.dart';
import 'screens/scheduled_jobs_hub_screen_new.dart';

class WorkerHome extends StatelessWidget {
  const WorkerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WorkerHomeContent();
  }
}

class _WorkerHomeContent extends StatefulWidget {
  const _WorkerHomeContent();

  @override
  State<_WorkerHomeContent> createState() => _WorkerHomeContentState();
}

class _WorkerHomeContentState extends State<_WorkerHomeContent> {
  int _currentIndex = 1; // Start on Scheduled Jobs tab (index 1)

  Widget _screenForIndex(int index) {
    switch (index) {
      case 0:
        return WorkerMoneyScreen(
          onNavigateToTab: (tabIndex) {
            if (!mounted) return;
            setState(() {
              _currentIndex = tabIndex;
            });
          },
        );
      case 1:
        return const ScheduledJobsHubScreenNew();
      case 2:
      default:
        return const WorkerAccountScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screenForIndex(_currentIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF1976D2),
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Money',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work),
              label: 'Scheduled Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
