import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Browse by category',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/all-services');
                },
                child: const Row(
                  children: [
                    Text('See all'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 0.8,
            children: [
              _buildCategoryItem(context, Icons.ac_unit, 'AC &\nCooler'),
              _buildCategoryItem(context, Icons.plumbing, 'Plumbing'),
              _buildCategoryItem(context, Icons.electrical_services, 'Electrician'),
              _buildCategoryItem(context, Icons.cleaning_services, 'Cleaning'),
              _buildCategoryItem(context, Icons.format_paint, 'Painting'),
              _buildCategoryItem(context, Icons.handyman, 'Carpenter'),
              _buildCategoryItem(context, Icons.pest_control, 'Pest\nControl'),
              _buildCategoryItem(context, Icons.more_horiz, 'More'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.teal.withValues(alpha: 0.2)
                    : Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}