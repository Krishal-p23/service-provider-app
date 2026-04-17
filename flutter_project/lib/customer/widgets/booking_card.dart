import 'package:flutter/material.dart';
import '../models/booking.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final String workerName;
  final String serviceName;
  final String? workerPhoto;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;
  final VoidCallback? onPayNow;
  final VoidCallback? onRate;
  final bool hasReview;

  const BookingCard({
    super.key,
    required this.booking,
    required this.workerName,
    required this.serviceName,
    this.workerPhoto,
    this.onTap,
    this.onCancel,
    this.onComplete,
    this.onPayNow,
    this.onRate,
    this.hasReview = false,
  });

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return theme.primaryColor;
      case 'completed':
        return Colors.green;
      case 'awaiting_payment':
        return Colors.deepOrange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Confirm Payment';
      case 'awaiting_payment':
        return 'Confirm Payment';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

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
                children: [
                  // Worker Photo
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    backgroundImage: workerPhoto != null
                        ? NetworkImage(workerPhoto!)
                        : null,
                    child: workerPhoto == null
                        ? Icon(Icons.person, color: theme.primaryColor)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Booking Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(serviceName, style: theme.textTheme.displaySmall),
                        const SizedBox(height: 4),
                        Text(workerName, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        booking.status,
                        theme,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getStatusColor(
                          booking.status,
                          theme,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusLabel(booking.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(booking.status, theme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Date & Time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(booking.scheduledDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeFormat.format(booking.scheduledDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),

              if (booking.rescheduledAt != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rescheduled by ${booking.rescheduledBy ?? 'worker'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      if ((booking.rescheduleReason ?? '').trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Reason: ${booking.rescheduleReason}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      if (booking.previousScheduledDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Previous: ${dateFormat.format(booking.previousScheduledDate!)} ${timeFormat.format(booking.previousScheduledDate!)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // OTP Section (for pending/confirmed bookings)
              if ((booking.status == 'pending' ||
                      booking.status == 'confirmed') &&
                  booking.activationOtp != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Activation OTP',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          booking.activationOtp!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      if (booking.otpExpiresAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Expires: ${timeFormat.format(booking.otpExpiresAt!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking ID: #${booking.id.toString().padLeft(6, '0')}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '₹${booking.totalAmount.toStringAsFixed(0)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Action Buttons
              if (booking.status == 'pending' ||
                  booking.status == 'confirmed' ||
                  booking.status == 'in_progress' ||
                  booking.status == 'awaiting_payment' ||
                  booking.status == 'completed') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Cancel Button (only for pending/confirmed)
                    if ((booking.status == 'pending' ||
                            booking.status == 'confirmed') &&
                        onCancel != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),

                    // Complete Button (only for in_progress)
                    if (booking.status == 'in_progress' &&
                        onComplete != null) ...[
                      if ((booking.status == 'pending' ||
                              booking.status == 'confirmed') &&
                          onCancel != null)
                        const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onComplete,
                          child: const Text('Confirm Payment'),
                        ),
                      ),
                    ],

                    // Pay Now button when worker marked job done
                    if (booking.status == 'awaiting_payment' &&
                        onPayNow != null) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onPayNow,
                          child: const Text('Pay Now'),
                        ),
                      ),
                    ],

                    // Rate & Review button for completed bookings
                    if (booking.status == 'completed' &&
                        onRate != null &&
                        !hasReview) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onRate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Rate & Review'),
                        ),
                      ),
                    ],

                    // Already Reviewed badge for completed bookings with reviews
                    if (booking.status == 'completed' && hasReview) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                          child: const Text('Already Reviewed'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
