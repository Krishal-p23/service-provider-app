// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/worker_provider.dart';
// import '../../screens/onboarding_screen.dart';

// class WorkerCultScreen extends StatelessWidget {
//   const WorkerCultScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final workerProvider = context.watch<WorkerProvider>();
//     final worker = workerProvider.currentWorker;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Account',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings_outlined),
//             onPressed: () {
//               // TODO: Navigate to settings
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 16),

//               // Profile Header
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF1976D2).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(40),
//                       ),
//                       child: const Icon(
//                         Icons.person,
//                         size: 40,
//                         color: Color(0xFF1976D2),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             worker?.name ?? 'Worker',
//                             style: const TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             worker?.mobile ?? '',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green.shade50,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: Colors.green.shade200,
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.verified,
//                                   size: 14,
//                                   color: Colors.green.shade700,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   'Verified Worker',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.green.shade700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // Stats Cards
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         'Jobs Completed',
//                         '${workerProvider.todayJobsCount}',
//                         Icons.check_circle_outline,
//                         Colors.blue,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildStatCard(
//                         'Rating',
//                         workerProvider.averageRating > 0
//                             ? '${workerProvider.averageRating.toStringAsFixed(1)} ★'
//                             : 'N/A',
//                         Icons.star_outline,
//                         Colors.amber,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),
//               const Divider(height: 1),
//               const SizedBox(height: 8),

//               // Personal Information Section
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//                 child: Text(
//                   'Personal Information',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//               _buildInfoTile(
//                 Icons.person_outline,
//                 'Full Name',
//                 worker?.name ?? 'Not set',
//                 () {},
//               ),

//               _buildInfoTile(
//                 Icons.phone_outlined,
//                 'Mobile Number',
//                 worker?.mobile ?? 'Not set',
//                 () {},
//               ),

//               _buildInfoTile(
//                 Icons.email_outlined,
//                 'Email',
//                 worker?.email ?? 'Not set',
//                 () {},
//               ),

//               _buildInfoTile(
//                 Icons.location_on_outlined,
//                 'Address',
//                 worker?.address ?? 'Not set',
//                 () {},
//               ),

//               const SizedBox(height: 8),
//               const Divider(height: 1),
//               const SizedBox(height: 8),

//               // Work Details Section
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//                 child: Text(
//                   'Work Details',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//               _buildActionTile(
//                 Icons.verified_user_outlined,
//                 'Verification Status',
//                 'View your verification documents',
//                 () {},
//               ),

//               _buildActionTile(
//                 Icons.account_balance_outlined,
//                 'Bank Details',
//                 'Manage your payment methods',
//                 () {},
//               ),

//               _buildActionTile(
//                 Icons.work_history_outlined,
//                 'Work History',
//                 'View your completed jobs',
//                 () {},
//               ),

//               _buildActionTile(
//                 Icons.star_border_outlined,
//                 'Reviews & Ratings',
//                 'See what customers say about you',
//                 () {},
//               ),

//               const SizedBox(height: 24),

//               // Logout Button
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     onPressed: () async {
//                       final shouldLogout = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text('Logout'),
//                           content:
//                               const Text('Are you sure you want to logout?'),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, false),
//                               child: const Text('Cancel'),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, true),
//                               style: TextButton.styleFrom(
//                                 foregroundColor: Colors.red,
//                               ),
//                               child: const Text('Logout'),
//                             ),
//                           ],
//                         ),
//                       );

//                       if (shouldLogout == true && context.mounted) {
//                         await workerProvider.logout();
//                         if (context.mounted) {
//                           Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const OnboardingScreen(),
//                             ),
//                             (route) => false,
//                           );
//                         }
//                       }
//                     },
//                     icon: const Icon(Icons.logout, color: Colors.red),
//                     label: const Text(
//                       'Logout',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       side: const BorderSide(color: Colors.red),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(
//       String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: color.withOpacity(0.3),
//         ),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade700,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoTile(
//     IconData icon,
//     String label,
//     String value,
//     VoidCallback onTap,
//   ) {
//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, size: 20, color: Colors.grey.shade700),
//       ),
//       title: Text(
//         label,
//         style: TextStyle(
//           fontSize: 13,
//           color: Colors.grey.shade600,
//         ),
//       ),
//       subtitle: Text(
//         value,
//         style: const TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.w500,
//           color: Colors.black87,
//         ),
//       ),
//       trailing:
//           Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade600),
//       onTap: onTap,
//     );
//   }

//   Widget _buildActionTile(
//     IconData icon,
//     String title,
//     String subtitle,
//     VoidCallback onTap,
//   ) {
//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: const Color(0xFF1976D2).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, size: 20, color: const Color(0xFF1976D2)),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(
//           fontSize: 12,
//           color: Colors.grey.shade600,
//         ),
//       ),
//       trailing: const Icon(Icons.chevron_right, size: 20),
//       onTap: onTap,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../screens/onboarding_screen.dart';

class WorkerCultScreen extends StatelessWidget {
  const WorkerCultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final worker = workerProvider.currentWorker;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Profile Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF1976D2),
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            worker?.mobile ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified Worker',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Jobs Completed',
                        '${workerProvider.todayJobsCount}',
                        Icons.check_circle_outline,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Rating',
                        workerProvider.averageRating > 0
                            ? '${workerProvider.averageRating.toStringAsFixed(1)} ★'
                            : 'N/A',
                        Icons.star_outline,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Personal Information Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              _buildInfoTile(
                Icons.person_outline,
                'Full Name',
                worker?.name ?? 'Not set',
                () {},
              ),

              _buildInfoTile(
                Icons.phone_outlined,
                'Mobile Number',
                worker?.mobile ?? 'Not set',
                () {},
              ),

              _buildInfoTile(
                Icons.email_outlined,
                'Email',
                worker?.email ?? 'Not set',
                () {},
              ),

              _buildInfoTile(
                Icons.location_on_outlined,
                'Address',
                worker?.address ?? 'Not set',
                () {},
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Work Details Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Text(
                  'Work Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              _buildActionTile(
                Icons.verified_user_outlined,
                'Verification Status',
                'View your verification documents',
                () {},
              ),

              _buildActionTile(
                Icons.account_balance_outlined,
                'Bank Details',
                'Manage your payment methods',
                () {},
              ),

              _buildActionTile(
                Icons.work_history_outlined,
                'Work History',
                'View your completed jobs',
                () {},
              ),

              _buildActionTile(
                Icons.star_border_outlined,
                'Reviews & Ratings',
                'See what customers say about you',
                () {},
              ),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
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
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade700),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing:
          Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade600),
      onTap: onTap,
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1976D2)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}