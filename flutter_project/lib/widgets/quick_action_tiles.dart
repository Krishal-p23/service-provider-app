import 'package:flutter/material.dart';

class QuickActionTiles extends StatelessWidget {
  const QuickActionTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: theme.cardColor,
      child: SizedBox(
        height: 90,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            _buildTile(context, Icons.plumbing, 'Plumbing', isDark),
            _buildTile(context, Icons.electrical_services, 'Electrician', isDark),
            _buildTile(context, Icons.cleaning_services, 'Cleaning', isDark),
            _buildTile(context, Icons.ac_unit, 'AC Repair', isDark),
            _buildTile(context, Icons.format_paint, 'Painting', isDark),
            _buildTile(context, Icons.handyman, 'Carpenter', isDark),
            _buildTile(context, Icons.pest_control, 'Pest Control', isDark),
            _buildTile(context, Icons.tv, 'Appliance', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String label, bool isDark) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.teal.withValues(alpha: 0.2)
                    : Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}