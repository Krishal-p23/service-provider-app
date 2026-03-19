// // import 'package:flutter/material.dart';

// // class CategoryGrid extends StatelessWidget {
// //   const CategoryGrid({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'Browse by category',
// //                 style: Theme.of(context).textTheme.displaySmall,
// //               ),
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.pushNamed(context, '/all-services');
// //                 },
// //                 child: const Row(
// //                   children: [
// //                     Text('See all'),
// //                     SizedBox(width: 4),
// //                     Icon(Icons.arrow_forward_ios, size: 14),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 12),
// //           GridView.count(
// //             crossAxisCount: 4,
// //             shrinkWrap: true,
// //             physics: const NeverScrollableScrollPhysics(),
// //             mainAxisSpacing: 12,
// //             crossAxisSpacing: 8,
// //             childAspectRatio: 0.8,
// //             children: [
// //               _buildCategoryItem(context, Icons.ac_unit, 'AC &\nCooler'),
// //               _buildCategoryItem(context, Icons.plumbing, 'Plumbing'),
// //               _buildCategoryItem(context, Icons.electrical_services, 'Electrician'),
// //               _buildCategoryItem(context, Icons.cleaning_services, 'Cleaning'),
// //               _buildCategoryItem(context, Icons.format_paint, 'Painting'),
// //               _buildCategoryItem(context, Icons.handyman, 'Carpenter'),
// //               _buildCategoryItem(context, Icons.pest_control, 'Pest\nControl'),
// //               _buildCategoryItem(context, Icons.more_horiz, 'More'),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildCategoryItem(BuildContext context, IconData icon, String label) {
// //     final theme = Theme.of(context);
// //     final isDark = theme.brightness == Brightness.dark;

// //     return InkWell(
// //       onTap: () {},
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: theme.cardColor,
// //           borderRadius: BorderRadius.circular(8),
// //           border: Border.all(
// //             color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               width: 40,
// //               height: 40,
// //               decoration: BoxDecoration(
// //                 color: isDark
// //                     ? Colors.teal.withValues(alpha: 0.2)
// //                     : Colors.teal.withValues(alpha: 0.1),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Icon(
// //                 icon,
// //                 color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
// //                 size: 22,
// //               ),
// //             ),
// //             const SizedBox(height: 6),
// //             Text(
// //               label,
// //               textAlign: TextAlign.center,
// //               style: theme.textTheme.bodySmall?.copyWith(
// //                 fontWeight: FontWeight.w500,
// //               ),
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

// class CategoryGrid extends StatelessWidget {
//   final Function(int?, String)? onCategoryTap;

//   const CategoryGrid({
//     super.key,
//     this.onCategoryTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final serviceProvider = Provider.of<ServiceProvider>(context);
//     final categories = serviceProvider.getAllCategories();

//     return Container(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Browse by category',
//                 style: Theme.of(context).textTheme.displaySmall,
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Navigate to All Services Screen
//                   Navigator.pushNamed(context, '/all-services');
//                 },
//                 child: const Row(
//                   children: [
//                     Text('See all'),
//                     SizedBox(width: 4),
//                     Icon(Icons.arrow_forward_ios, size: 14),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           GridView.builder(
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               mainAxisSpacing: 12,
//               crossAxisSpacing: 8,
//               childAspectRatio: 0.8,
//             ),
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: categories.length > 8 ? 8 : categories.length,
//             itemBuilder: (context, index) {
//               final category = categories[index];
//               return _buildCategoryItem(
//                 context,
//                 _getCategoryIcon(category.categoryName),
//                 category.categoryName,
//                 category.id,
//               );
//             },
//           ),
//         ],
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

//   Widget _buildCategoryItem(
//     BuildContext context,
//     IconData icon,
//     String label,
//     int categoryId,
//   ) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return InkWell(
//       onTap: () {
//         if (onCategoryTap != null) {
//           onCategoryTap!(categoryId, label);
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: theme.cardColor,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? Colors.teal.withValues(alpha: 0.2)
//                     : Colors.teal.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 icon,
//                 color: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               child: Text(
//                 label,
//                 textAlign: TextAlign.center,
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
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
import '../../theme/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../utils/location_permission_helper.dart';
import '../services/location_service.dart';

class CategoryGrid extends StatelessWidget {
  final Function(int?, String)? onCategoryTap;

  const CategoryGrid({
    super.key,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final categories = serviceProvider.getAllCategories();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
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
                  // Navigate to All Services Screen
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
          const SizedBox(height: AppTheme.spacingMedium),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppTheme.spacingMedium,
              crossAxisSpacing: AppTheme.spacingSmall,
              childAspectRatio: 0.8,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length > 8 ? 8 : categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryItem(
                context,
                _getCategoryIcon(category.categoryName),
                category.categoryName,
                category.id,
              );
            },
          ),
        ],
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

  Widget _buildCategoryItem(
    BuildContext context,
    IconData icon,
    String label,
    int categoryId,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () async {
        // Request location permission before navigating to category
        final shouldProceed = await _requestLocationIfNeeded(context, label);
        
        // After location handling, trigger the category tap callback
        if (shouldProceed && onCategoryTap != null) {
          onCategoryTap!(categoryId, label);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          border: Border.all(
            color: AppTheme.getDividerColor(context),
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
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: isDark ? AppTheme.primaryLight : AppTheme.primaryDark,
                size: 22,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall - 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _requestLocationIfNeeded(BuildContext context, String categoryName) async {
    // Show dialog asking if user wants to enable location
    final bool? userWantsLocation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_on, color: theme.primaryColor),
              const SizedBox(width: AppTheme.spacingSmall),
              const Text('Enable Location?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are browsing $categoryName services.',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              const Text(
                'Enabling location will help us:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      'Find service providers near you',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSmall - 2),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      'Show accurate distance & time',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSmall - 2),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green),
                  SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      'Auto-fill your service address',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );

    if (userWantsLocation == true && context.mounted) {
      // Request location permission
      await LocationService.handleLocationRequest(context);
    }
    
    // Always proceed with navigation regardless of location choice
    return true;
  }
}