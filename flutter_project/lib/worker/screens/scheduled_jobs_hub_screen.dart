import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'scheduled_jobs_day_screen.dart';
import 'scheduled_jobs_week_screen.dart';
import 'scheduled_jobs_month_screen.dart';

class ScheduledJobsHubScreen extends StatelessWidget {
  const ScheduledJobsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDarkMode
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final subtextColor = AppTheme.getTextColor(context, secondary: true);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: const Text(
          'Scheduled Jobs',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.workerPrimaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'View your scheduled jobs',
              style: TextStyle(fontSize: 16, color: subtextColor),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildJobCard(
                    context: context,
                    title: 'Jobs for the Day',
                    subtitle: 'View today\'s scheduled jobs',
                    jobCount: '3 jobs',
                    icon: Icons.today,
                    color: AppTheme.workerPrimaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScheduledJobsDayScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildJobCard(
                    context: context,
                    title: 'Jobs for the Week',
                    subtitle: 'View this week\'s scheduled jobs',
                    jobCount: '8 jobs',
                    icon: Icons.calendar_view_week,
                    color: AppTheme.workerPrimaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScheduledJobsWeekScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildJobCard(
                    context: context,
                    title: 'Jobs for the Month',
                    subtitle: 'View this month\'s scheduled jobs',
                    jobCount: '15 jobs',
                    icon: Icons.calendar_month,
                    color: AppTheme.workerPrimaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ScheduledJobsMonthScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String jobCount,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDarkMode
        ? AppTheme.darkSurface
        : AppTheme.lightSurface;
    final cardBorderColor = isDarkMode
        ? AppTheme.darkDivider
        : AppTheme.lightDivider;
    final titleColor = AppTheme.getTextColor(context);
    final subtitleColor = AppTheme.getTextColor(context, secondary: true);
    final iconBgColor = isDarkMode
        ? color.withOpacity(0.2)
        : color.withOpacity(0.1);
    final arrowColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: subtitleColor),
                    ),
                  ],
                ),
              ),
              // Job count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  jobCount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Arrow icon
              Icon(Icons.arrow_forward_ios, color: arrowColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
