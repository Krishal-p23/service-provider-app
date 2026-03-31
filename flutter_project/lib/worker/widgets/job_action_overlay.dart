import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/map_launcher.dart';
import '../models/job.dart';

class JobActionOverlay extends StatelessWidget {
  final Job job;
  final bool isTopJob;
  final VoidCallback onActivate;
  final VoidCallback? onMarkDone;
  final VoidCallback onReschedule;
  final VoidCallback onDelete;

  const JobActionOverlay({
    super.key,
    required this.job,
    required this.isTopJob,
    required this.onActivate,
    this.onMarkDone,
    required this.onReschedule,
    required this.onDelete,
  });

  Future<void> _openCustomerNavigation(BuildContext context) async {
    if (job.customerLatitude == null || job.customerLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer coordinates are not available for this job.'),
        ),
      );
      return;
    }

    await MapLauncher.openNavigationToLocation(
      latitude: job.customerLatitude!,
      longitude: job.customerLongitude!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: surfaceColor,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.customerName,
                    style: const TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Job Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: dateFormat.format(job.scheduledTime),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    icon: Icons.access_time,
                    label: 'Time',
                    value: timeFormat.format(job.scheduledTime),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    icon: Icons.location_on,
                    label: 'Address',
                    value: job.address,
                  ),
                  if (job.customerDistanceKm != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: Icons.near_me,
                      label: 'Distance',
                      value: '${job.customerDistanceKm!.toStringAsFixed(1)} km from you',
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    icon: Icons.currency_rupee,
                    label: 'Amount',
                    value: '₹${job.amount.toStringAsFixed(0)}',
                    valueColor: primaryColor,
                    valueBold: true,
                  ),
                  if (job.customerLatitude != null && job.customerLongitude != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openCustomerNavigation(context),
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text('Open In Google Maps'),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            ),

            // Action Buttons - REMOVED isTopJob RESTRICTION
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (job.status.toLowerCase() == 'in_progress' &&
                            onMarkDone != null) {
                          onMarkDone!();
                          return;
                        }
                        onActivate();
                      },
                      icon: Icon(
                        job.status.toLowerCase() == 'in_progress'
                            ? Icons.check_circle_outline
                            : Icons.play_circle_outline,
                        size: 22,
                      ),
                      label: Text(
                        job.status.toLowerCase() == 'in_progress'
                            ? 'Mark Job Complete'
                            : 'Activate Job',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onReschedule();
                          },
                          icon: const Icon(Icons.schedule, size: 20),
                          label: const Text('Reschedule'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDelete();
                          },
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
