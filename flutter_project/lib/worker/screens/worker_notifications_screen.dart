// import 'package:flutter/material.dart';

// class WorkerNotificationsScreen extends StatelessWidget {
//   const WorkerNotificationsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Notifications',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//         actions: [
//           TextButton(
//             onPressed: () {
//               // Mark all as read
//             },
//             child: const Text(
//               'Mark all read',
//               style: TextStyle(
//                 color: Color(0xFF1976D2),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Mock Notifications
//           _buildNotificationCard(
//             icon: Icons.account_balance_wallet,
//             iconColor: Colors.green,
//             title: 'Payment Processed',
//             message: 'Your earnings for this week have been processed',
//             time: '2 hours ago',
//             isUnread: true,
//           ),

//           const SizedBox(height: 12),

//           _buildNotificationCard(
//             icon: Icons.work,
//             iconColor: Colors.blue,
//             title: 'New Job Available',
//             message: 'A new job request matches your skills',
//             time: '5 hours ago',
//             isUnread: true,
//           ),

//           const SizedBox(height: 12),

//           _buildNotificationCard(
//             icon: Icons.star,
//             iconColor: Colors.amber,
//             title: 'New Review',
//             message: 'You received a 5-star review from a customer',
//             time: '1 day ago',
//             isUnread: false,
//           ),

//           const SizedBox(height: 12),

//           _buildNotificationCard(
//             icon: Icons.info_outline,
//             iconColor: Colors.orange,
//             title: 'Platform Update',
//             message: 'New features are now available in your dashboard',
//             time: '2 days ago',
//             isUnread: false,
//           ),

//           const SizedBox(height: 12),

//           _buildNotificationCard(
//             icon: Icons.verified,
//             iconColor: Colors.green,
//             title: 'Verification Complete',
//             message: 'Your documents have been verified successfully',
//             time: '3 days ago',
//             isUnread: false,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotificationCard({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String message,
//     required String time,
//     required bool isUnread,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isUnread ? Colors.blue.shade50 : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isUnread ? Colors.blue.shade200 : Colors.grey.shade300,
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: iconColor, size: 24),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight:
//                               isUnread ? FontWeight.bold : FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     if (isUnread)
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: const BoxDecoration(
//                           color: Color(0xFF1976D2),
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   message,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   time,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class WorkerNotificationsScreen extends StatelessWidget {
  const WorkerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mock Notifications
          _buildNotificationCard(
            icon: Icons.account_balance_wallet,
            iconColor: Colors.green,
            title: 'Payment Processed',
            message: 'Your earnings for this week have been processed',
            time: '2 hours ago',
            isUnread: true,
          ),

          const SizedBox(height: 12),

          _buildNotificationCard(
            icon: Icons.work,
            iconColor: Colors.blue,
            title: 'New Job Available',
            message: 'A new job request matches your skills',
            time: '5 hours ago',
            isUnread: true,
          ),

          const SizedBox(height: 12),

          _buildNotificationCard(
            icon: Icons.star,
            iconColor: Colors.amber,
            title: 'New Review',
            message: 'You received a 5-star review from a customer',
            time: '1 day ago',
            isUnread: false,
          ),

          const SizedBox(height: 12),

          _buildNotificationCard(
            icon: Icons.info_outline,
            iconColor: Colors.orange,
            title: 'Platform Update',
            message: 'New features are now available in your dashboard',
            time: '2 days ago',
            isUnread: false,
          ),

          const SizedBox(height: 12),

          _buildNotificationCard(
            icon: Icons.verified,
            iconColor: Colors.green,
            title: 'Verification Complete',
            message: 'Your documents have been verified successfully',
            time: '3 days ago',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? Colors.blue.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1976D2),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}