import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import 'job_details_screen.dart';

class ScheduledJobsMonthScreen extends StatelessWidget {
  const ScheduledJobsMonthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.getTextColor(context);
    final surfaceColor = AppTheme.getSurfaceColor(context);
    final dividerColor = AppTheme.getDividerColor(context);

    return Consumer<JobProvider>(
      builder: (context, jobProvider, _) {
        // Ensure we're showing month jobs
        if (jobProvider.currentFilter != JobFilter.month) {
          // This won't normally happen, but added for safety
          WidgetsBinding.instance.addPostFrameCallback((_) {
            jobProvider.setFilter(JobFilter.month);
          });
        }

        final jobs = jobProvider.scheduledJobs;
        final isLoading = jobProvider.isLoading;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Jobs for the Month',
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
            'No jobs scheduled for this month',
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
    final dateFormat = DateFormat('MMM d, h:mm a');

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
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.getDividerColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Icon(Icons.event, color: Colors.orange, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(job.scheduledTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(job.scheduledTime),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
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
                        Icons.access_time,
                        size: 13,
                        color: AppTheme.getTextColor(context, secondary: true),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(job.scheduledTime),
                        style: TextStyle(
                          fontSize: 13,
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
                        Icons.person_outline,
                        size: 13,
                        color: AppTheme.getTextColor(context, secondary: true),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.customerName,
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
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          job.duration,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${job.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.getTextColor(
                context,
                secondary: true,
              ).withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
