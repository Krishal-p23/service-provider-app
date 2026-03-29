import 'package:flutter/material.dart';
import '../../customer/services/api_service.dart';
import '../../theme/app_theme.dart';

class WorkerNotificationsScreen extends StatefulWidget {
  const WorkerNotificationsScreen({super.key});

  @override
  State<WorkerNotificationsScreen> createState() =>
      _WorkerNotificationsScreenState();
}

class _WorkerNotificationsScreenState extends State<WorkerNotificationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isMarkingAllRead = false;
  List<Map<String, dynamic>> _notifications = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.initialize();
      final result = await _apiService.getWorkerNotifications();
      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final rows = (data['notifications'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .toList();
        setState(() {
          _notifications = rows;
        });
      }
    } catch (_) {
      // Keep empty list fallback.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllRead() async {
    if (_isMarkingAllRead) return;

    setState(() {
      _isMarkingAllRead = true;
    });

    try {
      final result = await _apiService.markAllWorkerNotificationsRead();
      if (result['success'] == true && mounted) {
        setState(() {
          _notifications = _notifications
              .map((n) => {...n, 'is_read': true})
              .toList();
        });
      }
    } catch (_) {
      // No-op
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAllRead = false;
        });
      }
    }
  }

  String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inHours < 1) return '${diff.inMinutes} minutes ago';
      if (diff.inDays < 1) return '${diff.inHours} hours ago';
      return '${diff.inDays} days ago';
    } catch (_) {
      return raw;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'payment':
        return Icons.account_balance_wallet;
      case 'job':
        return Icons.work;
      case 'review':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color _iconColorForType(String type) {
    switch (type) {
      case 'payment':
        return Colors.green;
      case 'job':
        return Colors.blue;
      case 'review':
        return Colors.amber;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.getTextColor(context);
    final textSecondary = AppTheme.getTextColor(context, secondary: true);
    final surface = AppTheme.getSurfaceColor(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textPrimary,
          ),
        ),
        backgroundColor: surface,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          TextButton(
            onPressed: _notifications.isEmpty ? null : _markAllRead,
            child: Text(
              _isMarkingAllRead ? '...' : 'Mark all read',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: textSecondary, fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = _notifications[index];
                final type = n['type']?.toString() ?? 'info';
                return _buildNotificationCard(
                  context: context,
                  icon: _iconForType(type),
                  iconColor: _iconColorForType(type),
                  title: n['title']?.toString() ?? 'Notification',
                  message: n['message']?.toString() ?? '',
                  time: _formatTime(n['created_at']?.toString() ?? ''),
                  isUnread: !(n['is_read'] == true),
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.getTextColor(context);
    final textSecondary = AppTheme.getTextColor(context, secondary: true);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread
            ? (isDark ? const Color(0xFF1E2A38) : Colors.blue.shade50)
            : AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? (isDark ? const Color(0xFF2F4D6F) : Colors.blue.shade200)
              : AppTheme.getDividerColor(context),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          color: textPrimary,
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1976D2),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
