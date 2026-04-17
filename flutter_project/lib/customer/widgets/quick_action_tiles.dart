
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import '../../theme/app_theme.dart';

class QuickActionTiles extends StatelessWidget {
  final Function(int?, String)? onCategoryTap;

  const QuickActionTiles({
    super.key,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final categories = serviceProvider.getAllCategories();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: 88, // Fixed height to prevent overflow: 50 (icon) + 6 (spacing) + 32 (text ~2 lines)
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildTile(
              context,
              _getCategoryIcon(category.categoryName),
              category.categoryName,
              category.id,
              isDark,
            );
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
      case 'electrician':
        return Icons.electrical_services;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'carpentry':
      case 'carpenter':
        return Icons.handyman;
      case 'painting':
        return Icons.format_paint;
      case 'ac repair':
        return Icons.ac_unit;
      case 'pest control':
        return Icons.pest_control;
      case 'appliance repair':
        return Icons.tv;
      default:
        return Icons.home_repair_service;
    }
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String label,
    int categoryId,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        if (onCategoryTap != null) {
          onCategoryTap!(categoryId, label);
        }
      },
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXSmall),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: theme.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXSmall),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                height: 1.2,
              ),
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