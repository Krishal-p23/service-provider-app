// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/worker_provider.dart';
// import '../../screens/onboarding_screen.dart';
// import 'worker_notifications_screen.dart';
// import 'bank_transfers_screen.dart';
// import 'pending_deductions_screen.dart';

// class WorkerMoneyScreen extends StatefulWidget {
//   const WorkerMoneyScreen({super.key});

//   @override
//   State<WorkerMoneyScreen> createState() => _WorkerMoneyScreenState();
// }

// class _WorkerMoneyScreenState extends State<WorkerMoneyScreen> {
//   int _selectedMonthIndex = 5; // Feb is the 6th month (0-indexed)

//   final List<String> _months = [
//     'Sept',
//     'Oct',
//     'Nov',
//     'Dec',
//     'Jan',
//     'Feb',
//   ];

//   // Mock chart data (earnings per month)
//   final List<double> _chartData = [0, 0, 0, 0, 0, 0];

//   @override
//   Widget build(BuildContext context) {
//     final workerProvider = context.watch<WorkerProvider>();
//     final worker = workerProvider.currentWorker;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.menu),
//                       onPressed: () {
//                         _showMenuDrawer(context, workerProvider, worker);
//                       },
//                     ),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             children: [
//                               Text(
//                                 '0',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey.shade700,
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               Icon(Icons.credit_card,
//                                   size: 18, color: Colors.grey.shade600),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         IconButton(
//                           icon: const Icon(Icons.notifications_outlined),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     const WorkerNotificationsScreen(),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Money Title
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Text(
//                   'Money',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Earned this month card
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE8F5E9),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '₹0',
//                                 style: TextStyle(
//                                   fontSize: 32,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Earned this month',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.black54,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             size: 20,
//                             color: Colors.grey.shade600,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),

//                       // Simple bar chart placeholder
//                       SizedBox(
//                         height: 100,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: List.generate(_months.length, (index) {
//                             final isSelected = index == _selectedMonthIndex;
//                             final height = _chartData[index] > 0
//                                 ? _chartData[index]
//                                 : 8.0; // Min height for empty bars
//                             return Column(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Container(
//                                   width: 32,
//                                   height: height,
//                                   decoration: BoxDecoration(
//                                     color: isSelected
//                                         ? Colors.green.shade600
//                                         : Colors.green.shade200,
//                                     borderRadius: const BorderRadius.vertical(
//                                         top: Radius.circular(4)),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                               ],
//                             );
//                           }),
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       // Month selector
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: List.generate(_months.length, (index) {
//                           final isSelected = index == _selectedMonthIndex;
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _selectedMonthIndex = index;
//                               });
//                             },
//                             child: Column(
//                               children: [
//                                 Text(
//                                   _months[index],
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: isSelected
//                                         ? Colors.black87
//                                         : Colors.black45,
//                                     fontWeight: isSelected
//                                         ? FontWeight.w600
//                                         : FontWeight.normal,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 if (isSelected)
//                                   Container(
//                                     height: 2,
//                                     width: 30,
//                                     decoration: BoxDecoration(
//                                       color: Colors.black87,
//                                       borderRadius: BorderRadius.circular(1),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           );
//                         }),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Bank transfers section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const BankTransfersScreen(),
//                       ),
//                     );
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Bank transfers',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Icon(Icons.arrow_forward_ios,
//                           size: 16, color: Colors.grey.shade600),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Upcoming bank transfer cards
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '₹0',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               '03 - 05 Feb',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                             SizedBox(height: 12),
//                             Text(
//                               'Upcoming',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const BankTransfersScreen(),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Center(
//                             child: Column(
//                               children: [
//                                 SizedBox(height: 12),
//                                 Text(
//                                   'See all',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                     color: Color(0xFF1976D2),
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Icon(
//                                   Icons.arrow_forward,
//                                   color: Color(0xFF1976D2),
//                                   size: 20,
//                                 ),
//                                 SizedBox(height: 12),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Pending deductions section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const PendingDeductionsScreen(),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                                 color: Colors.grey.shade300, width: 1.5),
//                           ),
//                           child: Icon(
//                             Icons.account_balance_wallet_outlined,
//                             color: Colors.grey.shade700,
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'PENDING DEDUCTIONS',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black54,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 '₹0',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(Icons.arrow_forward_ios,
//                             size: 16, color: Colors.grey.shade600),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showMenuDrawer(
//       BuildContext context, WorkerProvider workerProvider, worker) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SizedBox(height: 12),
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 25,
//                     backgroundColor:
//                         const Color(0xFF1976D2).withOpacity(0.1),
//                     child: const Icon(
//                       Icons.person,
//                       color: Color(0xFF1976D2),
//                       size: 28,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           worker?.name ?? 'Worker',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           worker?.mobile ?? '',
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Divider(height: 1),
//             ListTile(
//               leading: const Icon(Icons.dashboard_outlined),
//               title: const Text('Dashboard'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.work_outline),
//               title: const Text('My Jobs'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Navigate to jobs screen
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.schedule_outlined),
//               title: const Text('Schedule'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Navigate to schedule screen
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.star_outline),
//               title: const Text('Reviews'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Navigate to reviews screen
//               },
//             ),
//             const Divider(height: 1),
//             ListTile(
//               leading: const Icon(Icons.settings_outlined),
//               title: const Text('Settings'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Navigate to settings screen
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.help_outline),
//               title: const Text('Help & Support'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // TODO: Navigate to help screen
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title:
//                   const Text('Logout', style: TextStyle(color: Colors.red)),
//               onTap: () async {
//                 Navigator.pop(context);
//                 final shouldLogout = await showDialog<bool>(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Logout'),
//                     content: const Text('Are you sure you want to logout?'),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context, false),
//                         child: const Text('Cancel'),
//                       ),
//                       TextButton(
//                         onPressed: () => Navigator.pop(context, true),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.red,
//                         ),
//                         child: const Text('Logout'),
//                       ),
//                     ],
//                   ),
//                 );

//                 if (shouldLogout == true && context.mounted) {
//                   await workerProvider.logout();
//                   if (context.mounted) {
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const OnboardingScreen(),
//                       ),
//                       (route) => false,
//                     );
//                   }
//                 }
//               },
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../screens/onboarding_screen.dart';
import 'worker_notifications_screen.dart';
import 'bank_transfers_screen.dart';
import 'pending_deductions_screen.dart';

class WorkerMoneyScreen extends StatefulWidget {
  const WorkerMoneyScreen({super.key});

  @override
  State<WorkerMoneyScreen> createState() => _WorkerMoneyScreenState();
}

class _WorkerMoneyScreenState extends State<WorkerMoneyScreen> {
  int _selectedMonthIndex = 5; // Feb is the 6th month (0-indexed)

  final List<String> _months = [
    'Sept',
    'Oct',
    'Nov',
    'Dec',
    'Jan',
    'Feb',
  ];

  // Hardcoded demo earnings data per month (in rupees)
  final Map<String, double> _earningsData = {
    'Sept': 3200,
    'Oct': 5400,
    'Nov': 1800,
    'Dec': 6100,
    'Jan': 4300,
    'Feb': 2750,
  };

  // Calculate chart data (normalized to 100px max height)
  List<double> get _chartData {
    final maxEarning = _earningsData.values.reduce((a, b) => a > b ? a : b);
    return _months
        .map((month) => (_earningsData[month]! / maxEarning) * 80)
        .toList();
  }

  // Get current month's earnings
  double get _currentEarnings => _earningsData[_months[_selectedMonthIndex]]!;

  // Upcoming transfer amount (Feb earnings)
  double get _upcomingTransfer => _earningsData['Feb']!;

  // Pending deductions
  final double _pendingDeductions = 450;

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final worker = workerProvider.currentWorker;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, size: 28),
                      onPressed: () {
                        _showMenuDrawer(context, workerProvider, worker);
                      },
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.credit_card,
                                  size: 18, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, size: 28),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WorkerNotificationsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Money Title - BOLD
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Money',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Earned this month card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${_currentEarnings.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Earned this month',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              size: 28,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Bar chart
                      SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(_months.length, (index) {
                            final isSelected = index == _selectedMonthIndex;
                            final height = _chartData[index];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 36,
                                  height: height,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isSelected
                                          ? [
                                              Colors.green.shade700,
                                              Colors.green.shade600
                                            ]
                                          : [
                                              Colors.green.shade300,
                                              Colors.green.shade200
                                            ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.green
                                                  .withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Month selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_months.length, (index) {
                          final isSelected = index == _selectedMonthIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMonthIndex = index;
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  _months[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.black87
                                        : Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isSelected ? 24 : 6,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.green.shade700
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bank transfers section - BOLD HEADING
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bank transfers',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BankTransfersScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Upcoming transfer card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BankTransfersScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: Color(0xFF1976D2),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'UPCOMING TRANSFER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${_upcomingTransfer.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '03 – 05 Feb',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pending deductions card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PendingDeductionsScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.orange,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PENDING DEDUCTIONS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${_pendingDeductions.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenuDrawer(
      BuildContext context, WorkerProvider workerProvider, worker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        const Color(0xFF1976D2).withOpacity(0.15),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF1976D2),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker?.name ?? 'Worker',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          worker?.mobile ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            _buildMenuItem(Icons.dashboard_outlined, 'Dashboard', () {
              Navigator.pop(context);
            }),
            _buildMenuItem(Icons.work_outline, 'My Jobs', () {
              Navigator.pop(context);
            }),
            _buildMenuItem(Icons.schedule_outlined, 'Schedule', () {
              Navigator.pop(context);
            }),
            _buildMenuItem(Icons.star_outline, 'Reviews', () {
              Navigator.pop(context);
            }),
            const Divider(height: 1),
            _buildMenuItem(Icons.settings_outlined, 'Settings', () {
              Navigator.pop(context);
            }),
            _buildMenuItem(Icons.help_outline, 'Help & Support', () {
              Navigator.pop(context);
            }),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true && context.mounted) {
                  await workerProvider.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}