// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/user_provider.dart';
// import '../widgets/history_card.dart';
// import '../models/service_booking.dart';

// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({super.key});

//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   final _searchController = TextEditingController();
//   String _selectedCategory = 'All';
//   double? _selectedRating;
//   String _selectedSort = 'Recent';
//   List<ServiceBooking> _filteredBookings = [];

//   @override
//   void initState() {
//     super.initState();
//     _applyFilters();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _applyFilters() {
//     final userProvider = context.read<UserProvider>();
//     setState(() {
//       _filteredBookings = userProvider.getFilteredBookings(
//         category: _selectedCategory,
//         minRating: _selectedRating,
//         sortBy: _selectedSort,
//       );

//       if (_searchController.text.isNotEmpty) {
//         final searchQuery = _searchController.text.toLowerCase();
//         _filteredBookings = _filteredBookings.where((booking) {
//           return booking.providerName.toLowerCase().contains(searchQuery) ||
//               booking.category.toLowerCase().contains(searchQuery) ||
//               booking.serviceName.toLowerCase().contains(searchQuery);
//         }).toList();
//       }
//     });
//   }

//   void _showFilterSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => StatefulBuilder(
//         builder: (context, setModalState) {
//           return SafeArea(
//             child: Padding(
//               padding: EdgeInsets.only(
//                 left: 20,
//                 right: 20,
//                 top: 20,
//                 bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Filter & Sort',
//                           style: Theme.of(context).textTheme.displaySmall,
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                     const Divider(),
//                     const SizedBox(height: 16),

//                     // Category Filter
//                     Text(
//                       'Category',
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                     ),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8,
//                       children: [
//                         'All',
//                         'AC Repair',
//                         'Plumbing',
//                         'Electrician',
//                         'Cleaning',
//                         'Carpenter',
//                         'Pest Control',
//                         'Appliance Repair',
//                         'Painting',
//                       ].map((category) {
//                         return FilterChip(
//                           label: Text(category),
//                           selected: _selectedCategory == category,
//                           onSelected: (selected) {
//                             setModalState(() {
//                               _selectedCategory = category;
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 20),

//                     // Rating Filter
//                     Text(
//                       'Minimum Rating',
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                     ),
//                     const SizedBox(height: 8),
//                     ListTile(
//                       title: const Text('All Ratings'),
//                       leading: Radio<double?>(
//                         value: null,
//                         groupValue: _selectedRating,
//                         onChanged: (double? value) {
//                           setModalState(() {
//                             _selectedRating = value;
//                           });
//                         },
//                       ),
//                       onTap: () {
//                         setModalState(() {
//                           _selectedRating = null;
//                         });
//                       },
//                     ),
//                     ListTile(
//                       title: const Text('4.5 and above'),
//                       leading: Radio<double?>(
//                         value: 4.5,
//                         groupValue: _selectedRating,
//                         onChanged: (double? value) {
//                           setModalState(() {
//                             _selectedRating = value;
//                           });
//                         },
//                       ),
//                       onTap: () {
//                         setModalState(() {
//                           _selectedRating = 4.5;
//                         });
//                       },
//                     ),
//                     ListTile(
//                       title: const Text('4.0 and above'),
//                       leading: Radio<double?>(
//                         value: 4.0,
//                         groupValue: _selectedRating,
//                         onChanged: (double? value) {
//                           setModalState(() {
//                             _selectedRating = value;
//                           });
//                         },
//                       ),
//                       onTap: () {
//                         setModalState(() {
//                           _selectedRating = 4.0;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     // Sort Options
//                     Text(
//                       'Sort By',
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                     ),
//                     const SizedBox(height: 8),
//                     ListTile(
//                       title: const Text('Recent First'),
//                       leading: Radio<String>(
//                         value: 'Recent',
//                         groupValue: _selectedSort,
//                         onChanged: (String? value) {
//                           setModalState(() {
//                             _selectedSort = value!;
//                           });
//                         },
//                       ),
//                       onTap: () {
//                         setModalState(() {
//                           _selectedSort = 'Recent';
//                         });
//                       },
//                     ),
//                     ListTile(
//                       title: const Text('Oldest First'),
//                       leading: Radio<String>(
//                         value: 'Old',
//                         groupValue: _selectedSort,
//                         onChanged: (String? value) {
//                           setModalState(() {
//                             _selectedSort = value!;
//                           });
//                         },
//                       ),
//                       onTap: () {
//                         setModalState(() {
//                           _selectedSort = 'Old';
//                         });
//                       },
//                     ),
//                     ListTile(
//                       title: const Text('Highest Rated'),
//                       leading: Radio<String>(
//                         value: 'Rating',
//                         groupValue: _selectedSort,
//                         onChanged: (String? value) {
//                           setModalState(() {
//                             _selectedSort = value!;
//                           });
//                         },
//                       ),
//                       onTap: () {
//                         setModalState(() {
//                           _selectedSort = 'Rating';
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     // Action Buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () {
//                               setModalState(() {
//                                 _selectedCategory = 'All';
//                                 _selectedRating = null;
//                                 _selectedSort = 'Recent';
//                               });
//                             },
//                             child: const Text('Cancel'),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 _applyFilters();
//                               });
//                               Navigator.pop(context);
//                             },
//                             child: const Text('Apply'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = context.watch<UserProvider>();
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     if (!userProvider.isLoggedIn) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.history,
//                 size: 80,
//                 color: theme.primaryColor.withValues(alpha: 0.3),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'No history available',
//                 style: theme.textTheme.displaySmall,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Please login to view your booking history',
//                 style: theme.textTheme.bodyMedium,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/login');
//                 },
//                 child: const Text('Login Now'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Booking History'),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(60),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: _searchController,
//               onChanged: (value) => _applyFilters(),
//               decoration: InputDecoration(
//                 hintText: 'Search bookings...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.filter_list),
//                   onPressed: _showFilterSheet,
//                 ),
//                 filled: true,
//                 fillColor:
//                     isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: _filteredBookings.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.search_off,
//                     size: 80,
//                     color: theme.primaryColor.withValues(alpha: 0.3),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     'No bookings found',
//                     style: theme.textTheme.displaySmall,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Try adjusting your filters',
//                     style: theme.textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.only(top: 8, bottom: 80),
//               itemCount: _filteredBookings.length,
//               itemBuilder: (context, index) {
//                 return HistoryCard(booking: _filteredBookings[index]);
//               },
//             ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../../providers/user_provider.dart';
import '../utils/mock_data.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedSort = 'Recent';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    String tempStatus = _selectedStatus;
    String tempSort = _selectedSort;

    return StatefulBuilder(
      builder: (context, setModalState) {
        final theme = Theme.of(context);

        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter & Sort',
                          style: theme.textTheme.displaySmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Status Filter
                    Text(
                      'Status',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        'All',
                        'Pending',
                        'Confirmed',
                        'In Progress',
                        'Completed',
                        'Cancelled',
                      ].map((status) {
                        return FilterChip(
                          label: Text(status),
                          selected: tempStatus == status,
                          onSelected: (selected) {
                            setModalState(() {
                              tempStatus = status;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Sort Options
                    Text(
                      'Sort By',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRadioOption(
                      'Recent First',
                      'Recent',
                      tempSort,
                      (value) {
                        setModalState(() {
                          tempSort = value!;
                        });
                      },
                      theme,
                    ),
                    _buildRadioOption(
                      'Oldest First',
                      'Old',
                      tempSort,
                      (value) {
                        setModalState(() {
                          tempSort = value!;
                        });
                      },
                      theme,
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedStatus = tempStatus;
                                _selectedSort = tempSort;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadioOption(
    String title,
    String value,
    String groupValue,
    ValueChanged<String?> onChanged,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelBooking(int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      final success = await bookingProvider.cancelBooking(bookingId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot cancel booking at this stage'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = userProvider.currentUser;

    if (!userProvider.isLoggedIn || currentUser == null) {
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

    // Get all bookings
    var allBookings = bookingProvider.getUserBookings(currentUser.id!);

    // Apply status filter
    if (_selectedStatus != 'All') {
      String statusFilter = _selectedStatus.toLowerCase().replaceAll(' ', '_');
      allBookings =
          allBookings.where((b) => b.status == statusFilter).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      allBookings = allBookings.where((booking) {
        final worker = MockDatabase.getWorkerById(booking.workerId);
        final workerUser =
            worker != null ? MockDatabase.getUserById(worker.userId) : null;
        final service = MockDatabase.getServiceById(booking.serviceId);

        final workerName = workerUser?.name.toLowerCase() ?? '';
        final serviceName = service?.serviceName.toLowerCase() ?? '';

        return workerName.contains(searchQuery) ||
            serviceName.contains(searchQuery);
      }).toList();
    }

    // Apply sorting
    if (_selectedSort == 'Recent') {
      allBookings.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    } else {
      allBookings.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
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
              onChanged: (value) => setState(() {}),
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
      body: allBookings.isEmpty
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
              itemCount: allBookings.length,
              itemBuilder: (context, index) {
                final booking = allBookings[index];
                final worker = MockDatabase.getWorkerById(booking.workerId);
                final workerUser = worker != null
                    ? MockDatabase.getUserById(worker.userId)
                    : null;
                final service = MockDatabase.getServiceById(booking.serviceId);

                return _buildBookingCard(
                  context,
                  booking,
                  workerUser?.name ?? 'Worker ${booking.workerId}',
                  service?.serviceName ?? 'Service',
                  worker?.profilePhoto,
                  theme,
                );
              },
            ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    dynamic booking,
    String workerName,
    String serviceName,
    String? workerPhoto,
    ThemeData theme,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    Color statusColor = _getStatusColor(booking.status);
    String statusLabel = _getStatusLabel(booking.status);
    bool canCancel = booking.status == 'pending' || booking.status == 'confirmed';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  backgroundImage:
                      workerPhoto != null ? NetworkImage(workerPhoto) : null,
                  child: workerPhoto == null
                      ? Icon(Icons.person, color: theme.primaryColor)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workerName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: theme.textTheme.bodyMedium?.color),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(booking.scheduledDate),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time,
                    size: 16, color: theme.textTheme.bodyMedium?.color),
                const SizedBox(width: 8),
                Text(
                  timeFormat.format(booking.scheduledDate),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking ID: #${booking.id.toString().padLeft(6, '0')}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '₹${booking.totalAmount.toStringAsFixed(0)}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (canCancel) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelBooking(booking.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Cancel Booking'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}