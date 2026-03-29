import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import 'job_details_screen.dart';

class ScheduledJobsDayScreen extends StatelessWidget {
  const ScheduledJobsDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.getTextColor(context);
    final surfaceColor = AppTheme.getSurfaceColor(context);
    final dividerColor = AppTheme.getDividerColor(context);

    return Consumer<JobProvider>(
      builder: (context, jobProvider, _) {
        // Ensure we're showing day jobs
        if (jobProvider.currentFilter != JobFilter.day) {
          // This won't normally happen, but added for safety
          WidgetsBinding.instance.addPostFrameCallback((_) {
            jobProvider.setFilter(JobFilter.day);
          });
        }

        final jobs = jobProvider.scheduledJobs;
        final isLoading = jobProvider.isLoading;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Jobs for the Day',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: textPrimary,
              ),
            ),
            backgroundColor: surfaceColor,
            elevation: 0,
            foregroundColor: textPrimary,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : jobs.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    return _buildJobCard(context, jobs[index]);
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = AppTheme.getTextColor(context, secondary: true);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No jobs scheduled for today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Job job) {
    final timeFormat = DateFormat('h:mm a');
    final surfaceColor = AppTheme.getSurfaceColor(context);
    final dividerColor = AppTheme.getDividerColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetailsScreen(job: job)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF1976D2),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeFormat.format(job.scheduledTime),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Job details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppTheme.getTextColor(context, secondary: true),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.customerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextColor(
                            context,
                            secondary: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.getTextColor(context, secondary: true),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.getTextColor(
                              context,
                              secondary: true,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          job.duration,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${job.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
