

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/service_provider.dart';
// import '../screens/users/search_results_screen.dart';
// import '../utils/app_theme.dart';

// class ServiceSearchDelegate extends SearchDelegate {
//   // Map service display names to category names for matching
//   final Map<String, Map<String, dynamic>> serviceMap = {
//     'plumbing': {'categoryName': 'Plumbing', 'icon': Icons.plumbing},
//     'plumber': {'categoryName': 'Plumbing', 'icon': Icons.plumbing},
//     'electrical': {'categoryName': 'Electrical', 'icon': Icons.electrical_services},
//     'electrician': {'categoryName': 'Electrical', 'icon': Icons.electrical_services},
//     'cleaning': {'categoryName': 'Cleaning', 'icon': Icons.cleaning_services},
//     'cleaner': {'categoryName': 'Cleaning', 'icon': Icons.cleaning_services},
//     'carpentry': {'categoryName': 'Carpentry', 'icon': Icons.handyman},
//     'carpenter': {'categoryName': 'Carpentry', 'icon': Icons.handyman},
//     'painting': {'categoryName': 'Painting', 'icon': Icons.format_paint},
//     'painter': {'categoryName': 'Painting', 'icon': Icons.format_paint},
//     'ac repair': {'categoryName': 'AC Repair', 'icon': Icons.ac_unit},
//     'ac': {'categoryName': 'AC Repair', 'icon': Icons.ac_unit},
//     'pest control': {'categoryName': 'Pest Control', 'icon': Icons.pest_control},
//     'pest': {'categoryName': 'Pest Control', 'icon': Icons.pest_control},
//     'appliance repair': {'categoryName': 'Appliance Repair', 'icon': Icons.tv},
//     'appliance': {'categoryName': 'Appliance Repair', 'icon': Icons.tv},
//   };

//   @override
//   ThemeData appBarTheme(BuildContext context) {
//     final theme = Theme.of(context);
//     return theme;
//   }

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () => query = '',
//       ),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () => close(context, null),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) => _buildSearchResults(context);

//   @override
//   Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

//   Widget _buildSearchResults(BuildContext context) {
//     final theme = Theme.of(context);
//     final serviceProvider = Provider.of<ServiceProvider>(context);
//     final categories = serviceProvider.getAllCategories();

//     if (query.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search,
//               size: 80,
//               color: theme.primaryColor.withValues(alpha: 0.3),
//             ),
//             const SizedBox(height: AppTheme.spacingLarge),
//             Text(
//               'Search for services',
//               style: theme.textTheme.displaySmall,
//             ),
//             const SizedBox(height: AppTheme.spacingSmall),
//             Text(
//               'Try "plumber", "electrician", or "cleaning"',
//               style: theme.textTheme.bodyMedium,
//             ),
//           ],
//         ),
//       );
//     }

//     // Find matching categories from database
//     final lowercaseQuery = query.toLowerCase();
//     final suggestions = categories.where((category) {
//       final categoryNameLower = category.categoryName.toLowerCase();
//       // Check if category name contains the query
//       if (categoryNameLower.contains(lowercaseQuery)) {
//         return true;
//       }
//       // Check if any service map key matches
//       for (var entry in serviceMap.entries) {
//         if (entry.key.contains(lowercaseQuery) && 
//             entry.value['categoryName'] == category.categoryName) {
//           return true;
//         }
//       }
//       return false;
//     }).toList();

//     if (suggestions.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off,
//               size: 80,
//               color: theme.primaryColor.withValues(alpha: 0.3),
//             ),
//             const SizedBox(height: AppTheme.spacingLarge),
//             Text(
//               'No services found',
//               style: theme.textTheme.displaySmall,
//             ),
//             const SizedBox(height: AppTheme.spacingSmall),
//             Text(
//               'Try searching with different keywords',
//               style: theme.textTheme.bodyMedium,
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         final category = suggestions[index];
//         final icon = _getCategoryIcon(category.categoryName);
        
//         return ListTile(
//           leading: Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: theme.primaryColor.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
//             ),
//             child: Icon(
//               icon,
//               color: theme.primaryColor,
//               size: 24,
//             ),
//           ),
//           title: Text(
//             category.categoryName,
//             style: theme.textTheme.bodyLarge,
//           ),
//           trailing: Icon(
//             Icons.arrow_forward_ios,
//             size: 16,
//             color: theme.textTheme.bodySmall?.color,
//           ),
//           onTap: () {
//             // Close search and navigate to search results screen
//             close(context, null);
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => SearchResultsScreen(
//                   query: category.categoryName,
//                   categoryId: category.id,
//                 ),
//               ),
//             );
//           },
//         );
//       },
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
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import '../screens/users/search_results_screen.dart';
import '../../theme/app_theme.dart';
import '../services/location_service.dart'; // Added location service import

class ServiceSearchDelegate extends SearchDelegate {
  // Map service display names to category names for matching
  final Map<String, Map<String, dynamic>> serviceMap = {
    'plumbing': {'categoryName': 'Plumbing', 'icon': Icons.plumbing},
    'plumber': {'categoryName': 'Plumbing', 'icon': Icons.plumbing},
    'electrical': {'categoryName': 'Electrical', 'icon': Icons.electrical_services},
    'electrician': {'categoryName': 'Electrical', 'icon': Icons.electrical_services},
    'cleaning': {'categoryName': 'Cleaning', 'icon': Icons.cleaning_services},
    'cleaner': {'categoryName': 'Cleaning', 'icon': Icons.cleaning_services},
    'carpentry': {'categoryName': 'Carpentry', 'icon': Icons.handyman},
    'carpenter': {'categoryName': 'Carpentry', 'icon': Icons.handyman},
    'painting': {'categoryName': 'Painting', 'icon': Icons.format_paint},
    'painter': {'categoryName': 'Painting', 'icon': Icons.format_paint},
    'ac repair': {'categoryName': 'AC Repair', 'icon': Icons.ac_unit},
    'ac': {'categoryName': 'AC Repair', 'icon': Icons.ac_unit},
    'pest control': {'categoryName': 'Pest Control', 'icon': Icons.pest_control},
    'pest': {'categoryName': 'Pest Control', 'icon': Icons.pest_control},
    'appliance repair': {'categoryName': 'Appliance Repair', 'icon': Icons.tv},
    'appliance': {'categoryName': 'Appliance Repair', 'icon': Icons.tv},
  };

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final categories = serviceProvider.getAllCategories();

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: theme.primaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Search for services',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Try "plumber", "electrician", or "cleaning"',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final lowercaseQuery = query.toLowerCase();
    final suggestions = categories.where((category) {
      final categoryNameLower = category.categoryName.toLowerCase();
      if (categoryNameLower.contains(lowercaseQuery)) {
        return true;
      }
      for (var entry in serviceMap.entries) {
        if (entry.key.contains(lowercaseQuery) && 
            entry.value['categoryName'] == category.categoryName) {
          return true;
        }
      }
      return false;
    }).toList();

    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: theme.primaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'No services found',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Try searching with different keywords',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final category = suggestions[index];
        final icon = _getCategoryIcon(category.categoryName);
        
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Icon(
              icon,
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          title: Text(
            category.categoryName,
            style: theme.textTheme.bodyLarge,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.textTheme.bodySmall?.color,
          ),
          onTap: () async {
            // Request location permission before showing search results
            await _requestLocationForSearch(context, category.categoryName);
            
            // Close search and navigate to search results screen
            if (context.mounted) {
              close(context, null);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchResultsScreen(
                    query: category.categoryName,
                    categoryId: category.id,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  // Request location before showing search results
  Future<void> _requestLocationForSearch(BuildContext context, String categoryName) async {
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
                'You are searching for $categoryName services.',
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
      await LocationService.handleLocationRequest(context);
    }
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
}