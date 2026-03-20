import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/service_provider_card.dart';
import '../../utils/mock_data.dart';
import '../../../theme/app_theme.dart';
import 'service_provider_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  final int? categoryId;

  const SearchResultsScreen({
    super.key,
    required this.query,
    this.categoryId,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String _sortBy = 'distance'; // 'distance', 'distance_desc', 'rating'
  double? _minRating;
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Search Results'),
        ),
        body: const Center(
          child: Text('Please log in to view results'),
        ),
      );
    }

    // Get filtered workers
    final workersData = serviceProvider.filterWorkers(
      userId: currentUser.id!,
      serviceId: widget.categoryId,
      sortBy: _sortBy,
      minRating: _minRating,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.query.isEmpty ? 'All Services' : widget.query,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Panel
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By Dropdown
                  Text(
                    'Sort By',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightBackground,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      border: Border.all(
                        color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMedium,
                          vertical: AppTheme.spacingXSmall,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        items: const [
                          DropdownMenuItem(
                            value: 'distance',
                            child: Text('Distance (Nearest First)'),
                          ),
                          DropdownMenuItem(
                            value: 'distance_desc',
                            child: Text('Distance (Farthest First)'),
                          ),
                          DropdownMenuItem(
                            value: 'rating',
                            child: Text('Rating (Highest First)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortBy = value);
                          }
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Minimum Rating Dropdown
                  Text(
                    'Minimum Rating',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightBackground,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      border: Border.all(
                        color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<double?>(
                        value: _minRating,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMedium,
                          vertical: AppTheme.spacingXSmall,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text('Any Rating'),
                          ),
                          DropdownMenuItem(
                            value: 3.0,
                            child: Text('3.0+ ⭐'),
                          ),
                          DropdownMenuItem(
                            value: 4.0,
                            child: Text('4.0+ ⭐'),
                          ),
                          DropdownMenuItem(
                            value: 4.5,
                            child: Text('4.5+ ⭐'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _minRating = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Results Count and Info
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLarge,
              vertical: AppTheme.spacingMedium,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 16,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: Text(
                        '${workersData.length} service provider${workersData.length == 1 ? '' : 's'} found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (workersData.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Row(
                    children: [
                      Icon(
                        _sortBy == 'rating' ? Icons.star : Icons.near_me,
                        size: 14,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Expanded(
                        child: Text(
                          _getSortDescription(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Results List
          Expanded(
            child: workersData.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingXLarge),
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
                            'No service providers found',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
                          Text(
                            'Try adjusting your filters or search query',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
                    itemCount: workersData.length,
                    itemBuilder: (context, index) {
                      final data = workersData[index];
                      final worker = data['worker'];
                      final distance = data['distance'];
                      final rating = data['rating'];
                      
                      final user = MockDatabase.getUserById(worker.userId);
                      final reviews = MockDatabase.getReviewsByWorkerId(worker.id);
                      
                      return ServiceProviderCard(
                        worker: worker,
                        user: user,
                        distance: distance,
                        rating: rating,
                        completedJobs: reviews.length,
                        category: widget.categoryId != null 
                            ? MockDatabase.getCategoryById(widget.categoryId!)?.categoryName
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceProviderDetailsScreen(
                                workerId: worker.id,
                              ),
                            ),
                          );
                        },
                        onBookNow: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceProviderDetailsScreen(
                                workerId: worker.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getSortDescription() {
    switch (_sortBy) {
      case 'distance':
        return 'Sorted by distance (nearest first)';
      case 'distance_desc':
        return 'Sorted by distance (farthest first)';
      case 'rating':
        return 'Sorted by rating (highest first)';
      default:
        return '';
    }
  }
}