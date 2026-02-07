// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/service_provider.dart';
// import '../../providers/user_provider.dart';
// import '../../utils/mock_data.dart';
// import 'booking_details_screen.dart';
// import 'package:intl/intl.dart';

// class ServiceProviderDetailsScreen extends StatelessWidget {
//   final int workerId;

//   const ServiceProviderDetailsScreen({
//     super.key,
//     required this.workerId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final serviceProvider = Provider.of<ServiceProvider>(context);
//     final userProvider = Provider.of<UserProvider>(context);
//     final currentUser = userProvider.currentUser;

//     if (currentUser == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Service Provider')),
//         body: const Center(child: Text('Please log in')),
//       );
//     }

//     final workerDetails = serviceProvider.getWorkerDetails(workerId, currentUser.id!);
    
//     if (workerDetails == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Service Provider')),
//         body: const Center(child: Text('Service provider not found')),
//       );
//     }

//     final worker = workerDetails['worker'];
//     final user = workerDetails['user'];
//     final rating = workerDetails['rating'];
//     final reviewCount = workerDetails['reviewCount'];
//     final reviews = workerDetails['reviews'];
//     final services = workerDetails['services'];
//     final distance = workerDetails['distance'];
//     final completedJobs = workerDetails['completedJobs'];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Service Provider'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header Card
//             Card(
//               margin: EdgeInsets.zero,
//               shape: const RoundedRectangleBorder(),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     // Profile Picture
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
//                       backgroundImage: worker.profilePhoto != null
//                           ? NetworkImage(worker.profilePhoto!)
//                           : null,
//                       child: worker.profilePhoto == null
//                           ? Icon(
//                               Icons.person,
//                               size: 50,
//                               color: theme.primaryColor,
//                             )
//                           : null,
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Name
//                     Text(
//                       user?.name ?? 'Worker ${worker.id}',
//                       style: theme.textTheme.displayLarge,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
                    
//                     // Verified Badge
//                     if (worker.isVerified)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: theme.primaryColor.withValues(alpha: 0.1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.verified,
//                               size: 18,
//                               color: theme.primaryColor,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               'Verified Professional',
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 color: theme.primaryColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     const SizedBox(height: 20),
                    
//                     // Stats Row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _StatItem(
//                           icon: Icons.star,
//                           value: rating.toStringAsFixed(1),
//                           label: 'Rating',
//                           color: Colors.amber,
//                         ),
//                         _StatItem(
//                           icon: Icons.check_circle,
//                           value: completedJobs.toString(),
//                           label: 'Jobs Done',
//                           color: theme.primaryColor,
//                         ),
//                         _StatItem(
//                           icon: Icons.location_on,
//                           value: '${distance.toStringAsFixed(1)} km',
//                           label: 'Distance',
//                           color: Colors.blue,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Bio Section
//             if (worker.bio != null && worker.bio!.isNotEmpty) ...[
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'About',
//                       style: theme.textTheme.displaySmall,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       worker.bio!,
//                       style: theme.textTheme.bodyMedium,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
            
//             // Experience
//             if (worker.experienceYears != null) ...[
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     Icon(Icons.work_outline, color: theme.primaryColor),
//                     const SizedBox(width: 8),
//                     Text(
//                       '${worker.experienceYears} years of experience',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
            
//             // Services Offered
//             if (services.isNotEmpty) ...[
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Services Offered',
//                       style: theme.textTheme.displaySmall,
//                     ),
//                     const SizedBox(height: 12),
//                     ...services.map((service) => Card(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       child: ListTile(
//                         leading: Icon(
//                           Icons.build,
//                           color: theme.primaryColor,
//                         ),
//                         title: Text(service.serviceName),
//                         trailing: Text(
//                           '₹${service.basePrice.toStringAsFixed(0)}',
//                           style: theme.textTheme.displaySmall?.copyWith(
//                             color: theme.primaryColor,
//                           ),
//                         ),
//                       ),
//                     )).toList(),
//                   ],
//                 ),
//               ),
//             ],
            
//             // Reviews Section
//             if (reviews.isNotEmpty) ...[
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Reviews',
//                           style: theme.textTheme.displaySmall,
//                         ),
//                         Text(
//                           '$reviewCount reviews',
//                           style: theme.textTheme.bodyMedium,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     ...reviews.take(3).map((review) {
//                       final reviewer = MockDatabase.getUserById(review.userId);
//                       return Card(
//                         margin: const EdgeInsets.only(bottom: 8),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 16,
//                                     backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
//                                     child: Text(
//                                       reviewer?.name.substring(0, 1).toUpperCase() ?? 'U',
//                                       style: TextStyle(color: theme.primaryColor),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           reviewer?.name ?? 'User',
//                                           style: theme.textTheme.bodyMedium?.copyWith(
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         Text(
//                                           DateFormat('MMM dd, yyyy').format(review.createdAt),
//                                           style: theme.textTheme.bodySmall,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Row(
//                                     children: List.generate(5, (i) => Icon(
//                                       i < review.rating ? Icons.star : Icons.star_border,
//                                       size: 16,
//                                       color: Colors.amber,
//                                     )),
//                                   ),
//                                 ],
//                               ),
//                               if (review.comment != null && review.comment!.isNotEmpty) ...[
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   review.comment!,
//                                   style: theme.textTheme.bodyMedium,
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),
//             ],
            
//             const SizedBox(height: 80), // Bottom padding for button
//           ],
//         ),
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: ElevatedButton(
//             onPressed: services.isNotEmpty
//                 ? () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => BookingDetailsScreen(
//                           workerId: workerId,
//                           serviceId: services.first.id,
//                         ),
//                       ),
//                     );
//                   }
//                 : null,
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//             child: const Text('Book Now', style: TextStyle(fontSize: 16)),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _StatItem extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   final String label;
//   final Color color;

//   const _StatItem({
//     required this.icon,
//     required this.value,
//     required this.label,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
    
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 28),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: theme.textTheme.displaySmall?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: theme.textTheme.bodySmall,
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../../providers/user_provider.dart';
import '../../utils/mock_data.dart';
import 'booking_details_screen.dart';
import 'package:intl/intl.dart';

class ServiceProviderDetailsScreen extends StatelessWidget {
  final int workerId;

  const ServiceProviderDetailsScreen({
    super.key,
    required this.workerId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Provider')),
        body: const Center(child: Text('Please log in')),
      );
    }

    final workerDetails =
        serviceProvider.getWorkerDetails(workerId, currentUser.id!);

    if (workerDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Provider')),
        body: const Center(child: Text('Service provider not found')),
      );
    }

    final worker = workerDetails['worker'];
    final user = workerDetails['user'];
    final rating = workerDetails['rating'];
    final reviewCount = workerDetails['reviewCount'];
    final reviews = workerDetails['reviews'];
    final services = workerDetails['services'];
    final distance = workerDetails['distance'];
    final completedJobs = workerDetails['completedJobs'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          theme.primaryColor.withValues(alpha: 0.1),
                      backgroundImage: worker.profilePhoto != null
                          ? NetworkImage(worker.profilePhoto!)
                          : null,
                      child: worker.profilePhoto == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.primaryColor,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      user?.name ?? 'Worker ${worker.id}',
                      style: theme.textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Verified Badge
                    if (worker.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 18,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Verified Professional',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          icon: Icons.star,
                          value: rating.toStringAsFixed(1),
                          label: 'Rating',
                          color: Colors.amber,
                        ),
                        _StatItem(
                          icon: Icons.check_circle,
                          value: completedJobs.toString(),
                          label: 'Jobs Done',
                          color: theme.primaryColor,
                        ),
                        _StatItem(
                          icon: Icons.location_on,
                          value: '${distance.toStringAsFixed(1)} km',
                          label: 'Distance',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bio Section
            if (worker.bio != null && worker.bio!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      worker.bio!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],

            // Experience
            if (worker.experienceYears != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.work_outline, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      '${worker.experienceYears} years of experience',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Services Offered
            if (services.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services Offered',
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    ...services.map((service) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.build,
                              color: theme.primaryColor,
                            ),
                            title: Text(service.serviceName),
                            trailing: Text(
                              '₹${service.basePrice.toStringAsFixed(0)}',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],

            // Reviews Section
            if (reviews.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reviews',
                          style: theme.textTheme.displaySmall,
                        ),
                        Text(
                          '$reviewCount reviews',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...reviews.take(3).map((review) {
                      final reviewer = MockDatabase.getUserById(review.userId);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: theme.primaryColor
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      reviewer?.name
                                              .substring(0, 1)
                                              .toUpperCase() ??
                                          'U',
                                      style: TextStyle(
                                          color: theme.primaryColor),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reviewer?.name ?? 'User',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MMM dd, yyyy')
                                              .format(review.createdAt),
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                        5,
                                        (i) => Icon(
                                              i < review.rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 16,
                                              color: Colors.amber,
                                            )),
                                  ),
                                ],
                              ),
                              if (review.comment != null &&
                                  review.comment!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  review.comment!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 80), // Bottom padding for buttons
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: services.isNotEmpty
                      ? () {
                          if (!worker.isAvailable) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'This service provider is not available right now'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetailsScreen(
                                workerId: workerId,
                                serviceId: services.first.id,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}