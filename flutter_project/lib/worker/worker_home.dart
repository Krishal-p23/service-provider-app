// import 'package:flutter/material.dart';
// import 'screens/worker_money_screen.dart';
// import 'screens/worker_progress_screen.dart';
// import 'screens/worker_around_you_screen.dart';

// class WorkerHome extends StatefulWidget {
//   const WorkerHome({super.key});

//   @override
//   State<WorkerHome> createState() => _WorkerHomeState();
// }

// class _WorkerHomeState extends State<WorkerHome> {
//   int _currentIndex = 1; // Start on Money tab

//   final List<Widget> _screens = const [
//     WorkerProgressScreen(),
//     WorkerMoneyScreen(),
//     WorkerAroundYouScreen(),

//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           selectedItemColor: Colors.black,
//           unselectedItemColor: Colors.grey.shade400,
//           type: BottomNavigationBarType.fixed,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           selectedFontSize: 12,
//           unselectedFontSize: 12,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.track_changes_outlined),
//               activeIcon: Icon(Icons.track_changes),
//               label: 'Progress',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.account_balance_wallet_outlined),
//               activeIcon: Icon(Icons.account_balance_wallet),
//               label: 'Money',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.explore_outlined),
//               activeIcon: Icon(Icons.explore),
//               label: 'Around You',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'screens/worker_money_screen.dart';
// import 'screens/scheduled_jobs_hub_screen.dart';
// import 'package:flutter_project/worker/screens/worker_account_screen.dart';

// class WorkerHome extends StatefulWidget {
//   const WorkerHome({super.key});

//   @override
//   State<WorkerHome> createState() => _WorkerHomeState();
// }

// class _WorkerHomeState extends State<WorkerHome> {
//   int _currentIndex = 1; // Start on Scheduled Jobs tab (index 1)

//   final List<Widget> _screens = [
//     WorkerMoneyScreen(),
//     ScheduledJobsHubScreen(),
//     WorkerAccountScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           selectedItemColor: const Color(0xFF1976D2),
//           unselectedItemColor: Colors.grey.shade400,
//           type: BottomNavigationBarType.fixed,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           selectedFontSize: 12,
//           unselectedFontSize: 12,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.account_balance_wallet_outlined),
//               activeIcon: Icon(Icons.account_balance_wallet),
//               label: 'Money',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.work_outline),
//               activeIcon: Icon(Icons.work),
//               label: 'Scheduled Jobs',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//               label: 'Account',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'screens/worker_money_screen.dart';
// import 'screens/scheduled_jobs_hub_screen.dart';
// import 'screens/worker_account_screen.dart';
// import 'providers/worker_theme_provider.dart';

// class WorkerHome extends StatelessWidget {
//   const WorkerHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<WorkerThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           theme: _buildLightTheme(),
//           darkTheme: _buildDarkTheme(),
//           themeMode: themeProvider.materialThemeMode,
//           home: const _WorkerHomeContent(),
//         );
//       },
//     );
//   }

//   ThemeData _buildLightTheme() {
//     return ThemeData(
//       brightness: Brightness.light,
//       primaryColor: const Color(0xFF1976D2),
//       scaffoldBackgroundColor: Colors.grey[50],
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Color(0xFF1976D2),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       colorScheme: ColorScheme.light(
//         primary: const Color(0xFF1976D2),
//         secondary: const Color(0xFF1976D2),
//         surface: Colors.white,
//         background: Colors.grey[50]!,
//       ),
//     );
//   }

//   ThemeData _buildDarkTheme() {
//     return ThemeData(
//       brightness: Brightness.dark,
//       primaryColor: const Color(0xFF1976D2),
//       scaffoldBackgroundColor: const Color(0xFF121212),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Color(0xFF1E1E1E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       colorScheme: const ColorScheme.dark(
//         primary: Color(0xFF1976D2),
//         secondary: Color(0xFF1976D2),
//         surface: Color(0xFF1E1E1E),
//         background: Color(0xFF121212),
//       ),
//       cardColor: const Color(0xFF1E1E1E),
//     );
//   }
// }

// class _WorkerHomeContent extends StatefulWidget {
//   const _WorkerHomeContent();

//   @override
//   State<_WorkerHomeContent> createState() => _WorkerHomeContentState();
// }

// class _WorkerHomeContentState extends State<_WorkerHomeContent> {
//   int _currentIndex = 1; // Start on Scheduled Jobs tab (index 1)

//   final List<Widget> _screens = const [
//     WorkerMoneyScreen(),
//     ScheduledJobsHubScreen(),
//     WorkerAccountScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           selectedItemColor: const Color(0xFF1976D2),
//           unselectedItemColor: Colors.grey.shade400,
//           type: BottomNavigationBarType.fixed,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//           elevation: 0,
//           selectedFontSize: 12,
//           unselectedFontSize: 12,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.account_balance_wallet_outlined),
//               activeIcon: Icon(Icons.account_balance_wallet),
//               label: 'Money',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.work_outline),
//               activeIcon: Icon(Icons.work),
//               label: 'Scheduled Jobs',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//               label: 'Account',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'screens/worker_money_screen.dart';
// import 'screens/worker_progress_screen.dart';
// import 'screens/worker_around_you_screen.dart';

// class WorkerHome extends StatefulWidget {
//   const WorkerHome({super.key});

//   @override
//   State<WorkerHome> createState() => _WorkerHomeState();
// }

// class _WorkerHomeState extends State<WorkerHome> {
//   int _currentIndex = 1; // Start on Money tab

//   final List<Widget> _screens = const [
//     WorkerProgressScreen(),
//     WorkerMoneyScreen(),
//     WorkerAroundYouScreen(),

//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           selectedItemColor: Colors.black,
//           unselectedItemColor: Colors.grey.shade400,
//           type: BottomNavigationBarType.fixed,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           selectedFontSize: 12,
//           unselectedFontSize: 12,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.track_changes_outlined),
//               activeIcon: Icon(Icons.track_changes),
//               label: 'Progress',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.account_balance_wallet_outlined),
//               activeIcon: Icon(Icons.account_balance_wallet),
//               label: 'Money',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.explore_outlined),
//               activeIcon: Icon(Icons.explore),
//               label: 'Around You',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'screens/worker_money_screen.dart';
// import 'screens/scheduled_jobs_hub_screen_new.dart';
// import 'package:flutter_project/worker/screens/worker_account_screen.dart';

// class WorkerHome extends StatefulWidget {
//   const WorkerHome({super.key});

//   @override
//   State<WorkerHome> createState() => _WorkerHomeState();
// }

// class _WorkerHomeState extends State<WorkerHome> {
//   int _currentIndex = 1; // Start on Scheduled Jobs tab (index 1)

//   final List<Widget> _screens = [
//     WorkerMoneyScreen(),
//     ScheduledJobsHubScreenNew(),
//     WorkerAccountScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           selectedItemColor: const Color(0xFF1976D2),
//           unselectedItemColor: Colors.grey.shade400,
//           type: BottomNavigationBarType.fixed,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           selectedFontSize: 12,
//           unselectedFontSize: 12,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.account_balance_wallet_outlined),
//               activeIcon: Icon(Icons.account_balance_wallet),
//               label: 'Money',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.work_outline),
//               activeIcon: Icon(Icons.work),
//               label: 'Scheduled Jobs',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//               label: 'Account',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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

  final List<Widget> _screens = const [
    WorkerMoneyScreen(),
    ScheduledJobsHubScreenNew(),
    WorkerAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
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
