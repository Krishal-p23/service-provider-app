// import 'package:flutter/material.dart';
// import '../widgets/address_bar.dart';
// import '../widgets/quick_action_tiles.dart';
// import '../widgets/promotional_cards.dart';
// import '../widgets/trust_strip.dart';
// import '../widgets/category_grid.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _searchController = TextEditingController();
//   final List<String> _allServices = [
//     'AC & Cooler',
//     'Plumbing',
//     'Electrician',
//     'Cleaning',
//     'Painting',
//     'Carpenter',
//     'Pest Control',
//     'Appliance Repair',
//     'Masonry',
//     'Water Purifier',
//     'Home Salon',
//     'Washing Machine',
//     'Refrigerator',
//     'Microwave',
//     'Furniture',
//     'Window Cleaning',
//   ];
//   List<String> _filteredServices = [];
//   bool _isSearching = false;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _handleSearch(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _isSearching = false;
//         _filteredServices = [];
//       } else {
//         _isSearching = true;
//         _filteredServices = _allServices
//             .where((service) =>
//                 service.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Sticky Search Bar (only on home screen)
//             Container(
//               padding: const EdgeInsets.all(12),
//               color: theme.scaffoldBackgroundColor,
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: _handleSearch,
//                 decoration: InputDecoration(
//                   hintText: 'Search or ask a question',
//                   prefixIcon: Icon(
//                     Icons.search,
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                   ),
//                   suffixIcon: _isSearching
//                       ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             _searchController.clear();
//                             _handleSearch('');
//                           },
//                         )
//                       : Icon(
//                           Icons.mic_none,
//                           color: isDark
//                               ? Colors.grey.shade400
//                               : Colors.grey.shade600,
//                         ),
//                   filled: true,
//                   fillColor: isDark
//                       ? const Color(0xFF2C2C2C)
//                       : const Color(0xFFF5F5F5),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(
//                       color: isDark
//                           ? Colors.grey.shade700
//                           : Colors.grey.shade300,
//                     ),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(
//                       color: isDark
//                           ? Colors.grey.shade700
//                           : Colors.grey.shade300,
//                     ),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//             ),

//             // Address Bar
//             const AddressBar(),

//             // Quick Action Tiles (hidden during search)
//             if (!_isSearching) const QuickActionTiles(),

//             // Scrollable Content
//             Expanded(
//               child: _isSearching
//                   ? _buildSearchResults()
//                   : SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 12),

//                           // Promotional Cards
//                           const PromotionalCards(),

//                           const SizedBox(height: 12),

//                           // Trust Strip
//                           const TrustStrip(),

//                           const SizedBox(height: 12),

//                           // Category Grid
//                           const CategoryGrid(),

//                           const SizedBox(height: 80),
//                         ],
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchResults() {
//     final theme = Theme.of(context);

//     if (_filteredServices.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off,
//               size: 80,
//               color: theme.primaryColor.withValues(alpha: 0.3),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'No services found',
//               style: theme.textTheme.displaySmall,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Try searching with different keywords',
//               style: theme.textTheme.bodyMedium,
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: _filteredServices.length,
//       itemBuilder: (context, index) {
//         final service = _filteredServices[index];
//         return Card(
//           child: ListTile(
//             leading: Icon(
//               Icons.home_repair_service,
//               color: theme.primaryColor,
//             ),
//             title: Text(service),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('$service - UI only')),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../widgets/address_bar.dart';
// import '../widgets/quick_action_tiles.dart';
// import '../widgets/promotional_cards.dart';
// import '../widgets/trust_strip.dart';
// import '../widgets/category_grid.dart';
// import '../providers/service_provider.dart';
// import '../providers/user_provider.dart';
// import 'users/search_results_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final _searchController = TextEditingController();

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _handleSearch(String query) {
//     if (query.trim().isNotEmpty) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SearchResultsScreen(
//             query: query.trim(),
//           ),
//         ),
//       );
//     }
//   }

//   void _handleCategoryTap(int? categoryId, String categoryName) {
//     // Navigate to search results with category filter
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SearchResultsScreen(
//           query: categoryName,
//           categoryId: categoryId,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Sticky Search Bar
//             Container(
//               padding: const EdgeInsets.all(12),
//               color: theme.scaffoldBackgroundColor,
//               child: TextField(
//                 controller: _searchController,
//                 onSubmitted: _handleSearch,
//                 decoration: InputDecoration(
//                   hintText: 'Search for services...',
//                   prefixIcon: Icon(
//                     Icons.search,
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                   ),
//                   suffixIcon: Icon(
//                     Icons.mic_none,
//                     color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                   ),
//                   filled: true,
//                   fillColor: isDark
//                       ? const Color(0xFF2C2C2C)
//                       : const Color(0xFFF5F5F5),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(
//                       color: isDark
//                           ? Colors.grey.shade700
//                           : Colors.grey.shade300,
//                     ),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(
//                       color: isDark
//                           ? Colors.grey.shade700
//                           : Colors.grey.shade300,
//                     ),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//             ),

//             // Address Bar
//             const AddressBar(),

//             // Quick Action Tiles with navigation
//             QuickActionTiles(
//               onCategoryTap: _handleCategoryTap,
//             ),

//             // Scrollable Content
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 12),

//                     // Promotional Cards
//                     const PromotionalCards(),

//                     const SizedBox(height: 12),

//                     // Trust Strip
//                     const TrustStrip(),

//                     const SizedBox(height: 12),

//                     // Category Grid with navigation
//                     CategoryGrid(
//                       onCategoryTap: _handleCategoryTap,
//                     ),

//                     const SizedBox(height: 80),
//                   ],
//                 ),
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
import '../widgets/address_bar.dart';
import '../widgets/quick_action_tiles.dart';
import '../widgets/promotional_cards.dart';
import '../widgets/trust_strip.dart';
import '../widgets/category_grid.dart';
import '../providers/service_provider.dart';
import '../../providers/user_provider.dart';
import '../delegates/service_search_delegate.dart';
import '../../theme/app_theme.dart';
import 'users/search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSearch() {
    showSearch(
      context: context,
      delegate: ServiceSearchDelegate(),
    );
  }

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(
            query: query.trim(),
          ),
        ),
      );
    }
  }

  void _handleCategoryTap(int? categoryId, String categoryName) {
    // Navigate to search results with category filter
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          query: categoryName,
          categoryId: categoryId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Search Bar
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              color: theme.scaffoldBackgroundColor,
              child: TextField(
                controller: _searchController,
                onTap: () {
                  // Open search delegate when user taps the field
                  _openSearch();
                  // Unfocus to prevent keyboard from showing
                  FocusScope.of(context).unfocus();
                },
                onSubmitted: _handleSearch,
                readOnly: true, // Make read-only since we're using search delegate
                decoration: InputDecoration(
                  hintText: 'Search for services...',
                  hintStyle: TextStyle(
                    color: isDark 
                        ? AppTheme.darkTextSecondary 
                        : AppTheme.lightTextSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark 
                        ? AppTheme.darkTextSecondary 
                        : AppTheme.lightTextSecondary,
                  ),
                  suffixIcon: Icon(
                    Icons.mic_none,
                    color: isDark 
                        ? AppTheme.darkTextSecondary 
                        : AppTheme.lightTextSecondary,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppTheme.darkSurfaceVariant
                      : AppTheme.lightBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppTheme.darkDivider
                          : AppTheme.lightDivider,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppTheme.darkDivider
                          : AppTheme.lightDivider,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLarge,
                    vertical: AppTheme.spacingMedium,
                  ),
                ),
              ),
            ),

            // Address Bar
            const AddressBar(),

            // Quick Action Tiles with navigation
            QuickActionTiles(
              onCategoryTap: _handleCategoryTap,
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppTheme.spacingMedium),

                    // Promotional Cards
                    const PromotionalCards(),

                    const SizedBox(height: AppTheme.spacingMedium),

                    // Trust Strip
                    const TrustStrip(),

                    const SizedBox(height: AppTheme.spacingMedium),

                    // Category Grid with navigation
                    CategoryGrid(
                      onCategoryTap: _handleCategoryTap,
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}