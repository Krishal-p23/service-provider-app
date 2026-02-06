// import 'package:flutter/material.dart';

// class BankTransfersScreen extends StatelessWidget {
//   const BankTransfersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Bank Transfers',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Summary Card
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Total Transfers',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.white70,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   '₹0',
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Icon(Icons.info_outline, size: 16, color: Colors.white70),
//                     SizedBox(width: 8),
//                     Text(
//                       'Transfers happen every Monday',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           const Text(
//             'Upcoming Transfers',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Upcoming Transfer Card
//           _buildTransferCard(
//             date: '03 - 05 Feb',
//             amount: '₹0',
//             status: 'Upcoming',
//             statusColor: Colors.orange,
//             icon: Icons.schedule,
//           ),

//           const SizedBox(height: 24),

//           const Text(
//             'Past Transfers',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Empty State
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(32),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.account_balance_outlined,
//                     size: 64,
//                     color: Colors.grey.shade300,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No past transfers',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Your transfer history will appear here',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransferCard({
//     required String date,
//     required String amount,
//     required String status,
//     required Color statusColor,
//     required IconData icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: statusColor, size: 24),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   amount,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   date,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               status,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: statusColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class BankTransfersScreen extends StatelessWidget {
  const BankTransfersScreen({super.key});

  // Hardcoded past transfers data
  static final List<Map<String, dynamic>> _pastTransfers = [
    {
      'date': '27 – 29 Jan',
      'amount': 4300.0,
      'status': 'Completed',
      'statusColor': Colors.green,
      'icon': Icons.check_circle,
    },
    {
      'date': '23 – 25 Dec',
      'amount': 6100.0,
      'status': 'Completed',
      'statusColor': Colors.green,
      'icon': Icons.check_circle,
    },
    {
      'date': '25 – 27 Nov',
      'amount': 1800.0,
      'status': 'Completed',
      'statusColor': Colors.green,
      'icon': Icons.check_circle,
    },
    {
      'date': '28 – 30 Oct',
      'amount': 5400.0,
      'status': 'Completed',
      'statusColor': Colors.green,
      'icon': Icons.check_circle,
    },
    {
      'date': '23 – 25 Sept',
      'amount': 3200.0,
      'status': 'Completed',
      'statusColor': Colors.green,
      'icon': Icons.check_circle,
    },
  ];

  // Calculate total transfers
  static double get _totalTransfers {
    return _pastTransfers.fold(
        0, (sum, transfer) => sum + (transfer['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bank Transfers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Transfers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_totalTransfers.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Transfers happen every Monday',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Upcoming Transfers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Upcoming Transfer Card
          _buildTransferCard(
            date: '03 - 05 Feb',
            amount: 2750.0,
            status: 'Upcoming',
            statusColor: Colors.orange,
            icon: Icons.schedule,
          ),

          const SizedBox(height: 32),

          const Text(
            'Past Transfers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Past Transfers List
          ..._pastTransfers.map((transfer) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTransferCard(
                  date: transfer['date'],
                  amount: transfer['amount'],
                  status: transfer['status'],
                  statusColor: transfer['statusColor'],
                  icon: transfer['icon'],
                ),
              )),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTransferCard({
    required String date,
    required double amount,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: statusColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}