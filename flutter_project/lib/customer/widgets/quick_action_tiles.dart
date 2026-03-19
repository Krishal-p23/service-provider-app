// // import 'package:flutter/material.dart';
// // // Quick Action Tiles widget for Home Screen
// // class QuickActionTiles extends StatelessWidget {
// //   const QuickActionTiles({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final isDark = theme.brightness == Brightness.dark;

// //     return Container(
// //       padding: const EdgeInsets.symmetric(vertical: 12),
// //       color: theme.cardColor,
// //       child: SizedBox(
// //         height: 90,
// //         child: ListView(
// //           scrollDirection: Axis.horizontal,
// //           padding: const EdgeInsets.symmetric(horizontal: 8),
// //           children: [
// //             _buildTile(context, Icons.plumbing, 'Plumbing', isDark),
// //             _buildTile(context, Icons.electrical_services, 'Electrician', isDark),
// //             _buildTile(context, Icons.cleaning_services, 'Cleaning', isDark),
// //             _buildTile(context, Icons.ac_unit, 'AC Repair', isDark),
// //             _buildTile(context, Icons.format_paint, 'Painting', isDark),
// //             _buildTile(context, Icons.handyman, 'Carpenter', isDark),
// //             _buildTile(context, Icons.pest_control, 'Pest Control', isDark),
// //             _buildTile(context, Icons.tv, 'Appliance', isDark),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTile(BuildContext context, IconData icon, String label, bool isDark) {
// //     return InkWell(
// //       onTap: () {},
// //       child: Container(
// //         width: 75,
// //         margin: const EdgeInsets.symmetric(horizontal: 4),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               width: 50,
// //               height: 50,
// //               decoration: BoxDecoration(
// //                 color: isDark 
// //                     ? Colors.teal.withValues(alpha: 0.2)
// //                     : Colors.teal.withValues(alpha: 0.1),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Icon(
// //                 icon,
// //                 color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
// //                 size: 28,
// //               ),
// //             ),
// //             const SizedBox(height: 6),
// //             Text(
// //               label,
// //               style: Theme.of(context).textTheme.bodySmall,
// //               textAlign: TextAlign.center,
// //               maxLines: 2,
// //               overflow: TextOverflow.ellipsis,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/service_provider.dart';

// class QuickActionTiles extends StatelessWidget {
//   final Function(int?, String)? onCategoryTap;

//   const QuickActionTiles({
//     super.key,
//     this.onCategoryTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final serviceProvider = Provider.of<ServiceProvider>(context);
//     final categories = serviceProvider.getAllCategories();

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       color: theme.cardColor,
//       child: SizedBox(
//         height: 90,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           itemCount: categories.length,
//           itemBuilder: (context, index) {
//             final category = categories[index];
//             return _buildTile(
//               context,
//               _getCategoryIcon(category.categoryName),
//               category.categoryName,
//               category.id,
//               isDark,
//             );
//           },
//         ),
//       ),
//     );
//   }

//   IconData _getCategoryIcon(String categoryName) {
//     switch (categoryName.toLowerCase()) {
//       case 'plumbing':
//         return Icons.plumbing;
//       case 'electrical':
//       case 'electrician':
//         return Icons.electrical_services;
//       case 'cleaning':
//         return Icons.cleaning_services;
//       case 'carpentry':
//       case 'carpenter':
//         return Icons.handyman;
//       case 'painting':
//         return Icons.format_paint;
//       case 'ac repair':
//         return Icons.ac_unit;
//       case 'pest control':
//         return Icons.pest_control;
//       case 'appliance repair':
//         return Icons.tv;
//       default:
//         return Icons.home_repair_service;
//     }
//   }

//   Widget _buildTile(
//     BuildContext context,
//     IconData icon,
//     String label,
//     int categoryId,
//     bool isDark,
//   ) {
//     return InkWell(
//       onTap: () {
//         if (onCategoryTap != null) {
//           onCategoryTap!(categoryId, label);
//         }
//       },
//       child: Container(
//         width: 75,
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? Colors.teal.withValues(alpha: 0.2)
//                     : Colors.teal.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               label,
//               style: Theme.of(context).textTheme.bodySmall,
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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