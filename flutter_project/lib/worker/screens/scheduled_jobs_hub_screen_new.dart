import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../customer/services/api_service.dart';
import '../../theme/app_theme.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../widgets/current_job_card.dart';
import '../widgets/job_action_overlay.dart';
import '../screens/job_otp_verification_screen.dart';

class ScheduledJobsHubScreenNew extends StatefulWidget {
  const ScheduledJobsHubScreenNew({super.key});

  @override
  State<ScheduledJobsHubScreenNew> createState() =>
      _ScheduledJobsHubScreenNewState();
}

class _ScheduledJobsHubScreenNewState extends State<ScheduledJobsHubScreenNew> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = AppTheme.workerPrimaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Scheduled Jobs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          return Column(
            children: [
              // Current Job Card (shown only when there's an active job)
              if (jobProvider.activeJob != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CurrentJobCard(
                    job: jobProvider.activeJob!,
                    onReschedule: () => _handleReschedule(
                      context,
                      jobProvider,
                      jobProvider.activeJob!,
                    ),
                    onDelete: () => _handleDelete(
                      context,
                      jobProvider,
                      jobProvider.activeJob!,
                    ),
                  ),
                ),

              // Scheduled Jobs Card with Filter
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header with title
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C2C2C)
                                : Colors.grey.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'View Your Scheduled Jobs',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Filter Options
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFilterChip(
                                      context,
                                      label: 'Day',
                                      isSelected:
                                          jobProvider.currentFilter ==
                                          JobFilter.day,
                                      onTap: () =>
                                          jobProvider.setFilter(JobFilter.day),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildFilterChip(
                                      context,
                                      label: 'Week',
                                      isSelected:
                                          jobProvider.currentFilter ==
                                          JobFilter.week,
                                      onTap: () =>
                                          jobProvider.setFilter(JobFilter.week),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildFilterChip(
                                      context,
                                      label: 'Month',
                                      isSelected:
                                          jobProvider.currentFilter ==
                                          JobFilter.month,
                                      onTap: () => jobProvider.setFilter(
                                        JobFilter.month,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Jobs List
                        Expanded(
                          child: jobProvider.scheduledJobs.isEmpty
                              ? _buildEmptyState(jobProvider.currentFilter)
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: jobProvider.scheduledJobs.length,
                                  itemBuilder: (context, index) {
                                    final job =
                                        jobProvider.scheduledJobs[index];
                                    final isTopJob = index == 0;
                                    return _buildJobCard(
                                      context,
                                      job,
                                      isTopJob,
                                      jobProvider,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.workerPrimaryColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = isDark ? Colors.white : Colors.grey.shade700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(JobFilter filter) {
    String message;
    switch (filter) {
      case JobFilter.day:
        message = 'No jobs scheduled for today';
        break;
      case JobFilter.week:
        message = 'No jobs scheduled for this week';
        break;
      case JobFilter.month:
        message = 'No jobs scheduled for this month';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    Job job,
    bool isTopJob,
    JobProvider jobProvider,
  ) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = AppTheme.workerPrimaryColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return GestureDetector(
      onTap: () => _showJobActionOverlay(context, job, isTopJob, jobProvider),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTopJob ? primaryColor : borderColor,
            width: isTopJob ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: (isTopJob ? primaryColor : secondaryTextColor)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.access_time,
                    color: isTopJob ? primaryColor : secondaryTextColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeFormat.format(job.scheduledTime),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isTopJob ? primaryColor : secondaryTextColor,
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
                  if (isTopJob)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 12, color: primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'Next Job',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    job.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.customerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: secondaryTextColor,
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
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (job.customerDistanceKm != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.near_me_outlined,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${job.customerDistanceKm!.toStringAsFixed(1)} km from you',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dateFormat.format(job.scheduledTime),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${job.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios, size: 16, color: borderColor),
          ],
        ),
      ),
    );
  }

  void _showJobActionOverlay(
    BuildContext context,
    Job job,
    bool isTopJob,
    JobProvider jobProvider,
  ) {
    // IMPORTANT: the showDialog builder receives its own BuildContext (dialogContext).
    // We deliberately keep `context` (the screen-level BuildContext) in scope so that
    // Navigator.push resolves to the Worker app's Navigator, not the outer user Navigator.
    // Using the dialog's BuildContext after pop() would travel up to the outer MaterialApp
    // and give the OTP screen the wrong (user) theme.
    showDialog(
      context: context,
      builder: (dialogContext) => JobActionOverlay(
        job: job,
        isTopJob: isTopJob,
        onActivate: () => _handleActivate(context, jobProvider, job),
        onMarkDone: () => _handleMarkDone(context, jobProvider, job),
        onReschedule: () => _handleReschedule(context, jobProvider, job),
        onDelete: () => _handleDelete(context, jobProvider, job),
      ),
    );
  }

  Future<void> _handleMarkDone(
    BuildContext context,
    JobProvider jobProvider,
    Job job,
  ) async {
    final bookingId = int.tryParse(job.id);
    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid booking id. Cannot mark job done.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final apiService = ApiService();
    await apiService.initialize();
    final result = await apiService.markJobDone(bookingId: bookingId);

    if (!context.mounted) return;

    if (result['success'] == true) {
      await jobProvider.loadScheduledJobs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job marked complete. Awaiting customer payment.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final message =
        result['message']?.toString() ??
        result['data']?['message']?.toString() ??
        result['data']?['error']?.toString() ??
        'Failed to mark job done.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _handleActivate(
    BuildContext context,
    JobProvider jobProvider,
    Job job,
  ) async {
    final bookingId = int.tryParse(job.id);
    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid booking id. Cannot start OTP verification.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final apiService = ApiService();
    await apiService.initialize();
    final initiateResult = await apiService.initiateJobOTP(
      bookingId: bookingId,
    );

    if (!context.mounted) return;

    if (initiateResult['success'] != true) {
      final message =
          initiateResult['message']?.toString() ??
          initiateResult['data']?['message']?.toString() ??
          initiateResult['data']?['error']?.toString() ??
          'Failed to generate OTP. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final demoOtp = initiateResult['data']?['demo_otp']?.toString();
    if (demoOtp != null && demoOtp.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demo OTP: $demoOtp'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            JobOTPVerificationScreen(job: job, bookingId: bookingId),
      ),
    );
  }

  Future<void> _handleReschedule(
    BuildContext context,
    JobProvider jobProvider,
    Job job,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final bookingId = int.tryParse(job.id);
    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid booking id. Cannot reschedule this job.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    DateTime selectedDateTime = job.scheduledTime.add(const Duration(hours: 1));
    final reasonController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Reschedule Job',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job: ${job.title}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customer: ${job.customerName}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event),
                    title: const Text('New Date'),
                    subtitle: Text(
                      DateFormat('EEE, MMM d, yyyy').format(selectedDateTime),
                    ),
                    onTap: isSubmitting
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDateTime,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 180),
                              ),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDateTime = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  selectedDateTime.hour,
                                  selectedDateTime.minute,
                                );
                              });
                            }
                          },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: const Text('New Time'),
                    subtitle: Text(
                      DateFormat('h:mm a').format(selectedDateTime),
                    ),
                    onTap: isSubmitting
                        ? null
                        : () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                selectedDateTime,
                              ),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDateTime = DateTime(
                                  selectedDateTime.year,
                                  selectedDateTime.month,
                                  selectedDateTime.day,
                                  picked.hour,
                                  picked.minute,
                                );
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Reason for reschedule',
                      hintText: 'Example: Medical emergency / urgent issue',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final reason = reasonController.text.trim();
                        if (reason.length < 5) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a valid reason (min 5 characters).',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (selectedDateTime.isBefore(DateTime.now())) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please choose a future date and time.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        setDialogState(() {
                          isSubmitting = true;
                        });

                        final apiService = ApiService();
                        await apiService.initialize();
                        final result = await apiService.rescheduleBooking(
                          bookingId: bookingId,
                          scheduledDate: selectedDateTime,
                          reason: reason,
                        );

                        if (!mounted) return;

                        if (result['success'] == true) {
                          await jobProvider.loadScheduledJobs();
                          if (!mounted) return;
                          Navigator.of(context, rootNavigator: true).pop();
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Job rescheduled successfully and customer notified in app.',
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final message =
                            result['message']?.toString() ??
                            result['data']?['message']?.toString() ??
                            result['data']?['error']?.toString() ??
                            'Failed to reschedule booking.';
                        setDialogState(() {
                          isSubmitting = false;
                        });
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(message),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Reschedule'),
              ),
            ],
          ),
        );
      },
    );

    reasonController.dispose();
  }

  void _handleDelete(BuildContext context, JobProvider jobProvider, Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Job', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this job?',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.customerName,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontSize: 13, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              jobProvider.deleteJob(job.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Job deleted successfully'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
