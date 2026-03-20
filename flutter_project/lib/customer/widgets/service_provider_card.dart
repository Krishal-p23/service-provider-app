import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../models/user.dart';

class ServiceProviderCard extends StatelessWidget {
  final Worker worker;
  final User? user;
  final double distance;
  final double rating;
  final int completedJobs;
  final String? category;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;

  const ServiceProviderCard({
    super.key,
    required this.worker,
    this.user,
    required this.distance,
    required this.rating,
    required this.completedJobs,
    this.category,
    this.onTap,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    backgroundImage: worker.profilePhoto != null
                        ? NetworkImage(worker.profilePhoto!)
                        : null,
                    child: worker.profilePhoto == null
                        ? Icon(
                            Icons.person,
                            size: 30,
                            color: theme.primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Worker Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          user?.name ?? 'Worker ${worker.id}',
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 4),
                        
                        // Category
                        if (category != null)
                          Text(
                            category!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.primaryColor,
                            ),
                          ),
                        const SizedBox(height: 4),
                        
                        // Rating & Jobs
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$completedJobs jobs',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        
                        // Distance
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${distance.toStringAsFixed(1)} km away',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Verified Badge
                  if (worker.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              // Bio
              if (worker.bio != null && worker.bio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  worker.bio!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Experience
              if (worker.experienceYears != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 16,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${worker.experienceYears} years experience',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Book Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onBookNow ?? onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}