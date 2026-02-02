import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/history_card.dart';
import '../models/service_booking.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  double? _selectedRating;
  String _selectedSort = 'Recent';
  List<ServiceBooking> _filteredBookings = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final userProvider = context.read<UserProvider>();
    setState(() {
      _filteredBookings = userProvider.getFilteredBookings(
        category: _selectedCategory,
        minRating: _selectedRating,
        sortBy: _selectedSort,
      );

      if (_searchController.text.isNotEmpty) {
        final searchQuery = _searchController.text.toLowerCase();
        _filteredBookings = _filteredBookings.where((booking) {
          return booking.providerName.toLowerCase().contains(searchQuery) ||
              booking.category.toLowerCase().contains(searchQuery) ||
              booking.serviceName.toLowerCase().contains(searchQuery);
        }).toList();
      }
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter & Sort',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Category Filter
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        'All',
                        'AC Repair',
                        'Plumbing',
                        'Electrician',
                        'Cleaning',
                        'Carpenter',
                        'Pest Control',
                        'Appliance Repair',
                        'Painting',
                      ].map((category) {
                        return FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedCategory = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Rating Filter
                    Text(
                      'Minimum Rating',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('All Ratings'),
                      leading: Radio<double?>(
                        value: null,
                        groupValue: _selectedRating,
                        onChanged: (double? value) {
                          setModalState(() {
                            _selectedRating = value;
                          });
                        },
                      ),
                      onTap: () {
                        setModalState(() {
                          _selectedRating = null;
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('4.5 and above'),
                      leading: Radio<double?>(
                        value: 4.5,
                        groupValue: _selectedRating,
                        onChanged: (double? value) {
                          setModalState(() {
                            _selectedRating = value;
                          });
                        },
                      ),
                      onTap: () {
                        setModalState(() {
                          _selectedRating = 4.5;
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('4.0 and above'),
                      leading: Radio<double?>(
                        value: 4.0,
                        groupValue: _selectedRating,
                        onChanged: (double? value) {
                          setModalState(() {
                            _selectedRating = value;
                          });
                        },
                      ),
                      onTap: () {
                        setModalState(() {
                          _selectedRating = 4.0;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Sort Options
                    Text(
                      'Sort By',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('Recent First'),
                      leading: Radio<String>(
                        value: 'Recent',
                        groupValue: _selectedSort,
                        onChanged: (String? value) {
                          setModalState(() {
                            _selectedSort = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setModalState(() {
                          _selectedSort = 'Recent';
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Oldest First'),
                      leading: Radio<String>(
                        value: 'Old',
                        groupValue: _selectedSort,
                        onChanged: (String? value) {
                          setModalState(() {
                            _selectedSort = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setModalState(() {
                          _selectedSort = 'Old';
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Highest Rated'),
                      leading: Radio<String>(
                        value: 'Rating',
                        groupValue: _selectedSort,
                        onChanged: (String? value) {
                          setModalState(() {
                            _selectedSort = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setModalState(() {
                          _selectedSort = 'Rating';
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedCategory = 'All';
                                _selectedRating = null;
                                _selectedSort = 'Recent';
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _applyFilters();
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!userProvider.isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 80,
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 20),
              Text(
                'No history available',
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Please login to view your booking history',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Login Now'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _applyFilters(),
              decoration: InputDecoration(
                hintText: 'Search bookings...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterSheet,
                ),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _filteredBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No bookings found',
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: _filteredBookings.length,
              itemBuilder: (context, index) {
                return HistoryCard(booking: _filteredBookings[index]);
              },
            ),
    );
  }
}
