import 'package:flutter/material.dart';

class PromotionalCards extends StatelessWidget {
  const PromotionalCards({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildPromoCard(
            context,
            'FIRST50',
            '50% OFF on first booking',
            'New users only',
            Colors.orange,
            Colors.orange.shade100,
          ),
          _buildPromoCard(
            context,
            'SAVE200',
            'Get ₹200 cashback',
            'On services above ₹500',
            Colors.blue,
            Colors.blue.shade100,
          ),
          _buildPromoCard(
            context,
            'REFER100',
            'Refer & earn ₹100',
            'For every referral',
            Colors.green,
            Colors.green.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(
    BuildContext context,
    String code,
    String title,
    String subtitle,
    Color color,
    Color bgColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.2) : bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}