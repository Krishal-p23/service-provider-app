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

  const BookingCard({
    super.key,
    required this.booking,
    required this.workerName,
    required this.serviceName,
    this.workerPhoto,
    this.onTap,
    this.onCancel,
    this.onComplete,
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
        return 'Completed';
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
                        ? Icon(
                            Icons.person,
                            color: theme.primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Booking Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workerName,
                          style: theme.textTheme.bodyMedium,
                        ),
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
                      color: _getStatusColor(booking.status, theme)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getStatusColor(booking.status, theme)
                            .withValues(alpha: 0.3),
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
              
              const SizedBox(height: 12),
              
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
                  booking.status == 'in_progress') ...[
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
                    if (booking.status == 'in_progress' && onComplete != null) ...[
                      if ((booking.status == 'pending' || 
                           booking.status == 'confirmed') && 
                          onCancel != null)
                        const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onComplete,
                          child: const Text('Mark Complete'),
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