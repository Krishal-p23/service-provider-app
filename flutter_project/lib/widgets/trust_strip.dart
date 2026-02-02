import 'package:flutter/material.dart';

class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            context,
            Icons.security,
            'Secure',
            isDark,
          ),
          _buildItem(
            context,
            Icons.payment,
            'UPI Payments',
            isDark,
          ),
          _buildItem(
            context,
            Icons.verified,
            'Verified',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}