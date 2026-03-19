


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../providers/booking_provider.dart';
// import '../../providers/service_provider.dart';
// import '../../providers/user_provider.dart';
// import '../../utils/mock_data.dart';
// import '../main_screen.dart';

// class BookingDetailsScreen extends StatefulWidget {
//   final int workerId;
//   final int serviceId;

//   const BookingDetailsScreen({
//     super.key,
//     required this.workerId,
//     required this.serviceId,
//   });

//   @override
//   State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
// }

// class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
//   DateTime? _selectedDate;
//   String? _selectedTimeSlot;
//   bool _isLoading = false;

//   final List<String> _timeSlots = [
//     '09:00 AM - 11:00 AM',
//     '11:00 AM - 01:00 PM',
//     '02:00 PM - 04:00 PM',
//     '04:00 PM - 06:00 PM',
//     '06:00 PM - 08:00 PM',
//   ];

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 30)),
//     );

//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _confirmBooking() async {
//     if (_selectedDate == null || _selectedTimeSlot == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select date and time slot'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final bookingProvider =
//           Provider.of<BookingProvider>(context, listen: false);
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//       final serviceProvider =
//           Provider.of<ServiceProvider>(context, listen: false);

//       final service = serviceProvider.getServiceById(widget.serviceId);
//       final currentUser = userProvider.currentUser;

//       if (service == null || currentUser == null) {
//         throw Exception('Service or user not found');
//       }

//       // Parse time slot
//       final timeStr = _selectedTimeSlot!.split(' - ')[0];
//       final hour = int.parse(timeStr.split(':')[0]);
//       final isPM = timeStr.contains('PM');
//       final scheduledDate = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//         isPM && hour != 12 ? hour + 12 : hour,
//       );

//       // Create booking
//       await bookingProvider.createBooking(
//         userId: currentUser.id!,
//         workerId: widget.workerId,
//         serviceId: widget.serviceId,
//         scheduledDate: scheduledDate,
//         totalAmount: service.basePrice,
//       );

//       if (!mounted) return;

//       // Navigate to main screen with history tab
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const MainScreen(),
//         ),
//         (route) => false,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Booking confirmed successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final serviceProvider = Provider.of<ServiceProvider>(context);
//     final userProvider = Provider.of<UserProvider>(context);

//     final service = serviceProvider.getServiceById(widget.serviceId);
//     final worker = MockDatabase.getWorkerById(widget.workerId);
//     final workerUser =
//         worker != null ? MockDatabase.getUserById(worker.userId) : null;
//     final currentUser = userProvider.currentUser;
//     final userLocation = currentUser != null
//         ? MockDatabase.getUserLocation(currentUser.id!)
//         : null;

//     if (service == null || worker == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Booking Details')),
//         body: const Center(child: Text('Service or worker not found')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Booking Details'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Service Card
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Service Details',
//                       style: theme.textTheme.displaySmall,
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Icon(Icons.build, color: theme.primaryColor),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 service.serviceName,
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               Text(
//                                 'Base Price: ₹${service.basePrice.toStringAsFixed(0)}',
//                                 style: theme.textTheme.bodyMedium,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Worker Card
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Service Provider',
//                       style: theme.textTheme.displaySmall,
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 24,
//                           backgroundColor:
//                               theme.primaryColor.withValues(alpha: 0.1),
//                           backgroundImage: worker.profilePhoto != null
//                               ? NetworkImage(worker.profilePhoto!)
//                               : null,
//                           child: worker.profilePhoto == null
//                               ? Icon(Icons.person, color: theme.primaryColor)
//                               : null,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 workerUser?.name ?? 'Worker ${worker.id}',
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               if (worker.experienceYears != null)
//                                 Text(
//                                   '${worker.experienceYears} years experience',
//                                   style: theme.textTheme.bodyMedium,
//                                 ),
//                             ],
//                           ),
//                         ),
//                         if (worker.isVerified)
//                           Icon(Icons.verified, color: theme.primaryColor),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Date Selection
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Select Date',
//                       style: theme.textTheme.displaySmall,
//                     ),
//                     const SizedBox(height: 12),
//                     InkWell(
//                       onTap: () => _selectDate(context),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: theme.primaryColor),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.calendar_today,
//                                 color: theme.primaryColor),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 _selectedDate != null
//                                     ? DateFormat('EEEE, MMMM dd, yyyy')
//                                         .format(_selectedDate!)
//                                     : 'Select a date',
//                                 style: theme.textTheme.bodyLarge,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Time Slot Selection
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Select Time Slot',
//                       style: theme.textTheme.displaySmall,
//                     ),
//                     const SizedBox(height: 12),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: _timeSlots.map((slot) {
//                         final isSelected = _selectedTimeSlot == slot;
//                         return ChoiceChip(
//                           label: Text(slot),
//                           selected: isSelected,
//                           onSelected: (selected) {
//                             setState(() {
//                               _selectedTimeSlot = selected ? slot : null;
//                             });
//                           },
//                           selectedColor: theme.primaryColor,
//                           labelStyle: TextStyle(
//                             color: isSelected ? Colors.white : null,
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Location Card
//             if (userLocation != null)
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Service Location',
//                         style: theme.textTheme.displaySmall,
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Icon(Icons.location_on, color: theme.primaryColor),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               userLocation.address,
//                               style: theme.textTheme.bodyMedium,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 24),

//             // Total Amount
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: theme.primaryColor.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Total Amount',
//                     style: theme.textTheme.displaySmall,
//                   ),
//                   Text(
//                     '₹${service.basePrice.toStringAsFixed(0)}',
//                     style: theme.textTheme.displayMedium?.copyWith(
//                       color: theme.primaryColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: theme.cardColor,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: ElevatedButton(
//             onPressed: _isLoading ? null : _confirmBooking,
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//             child: _isLoading
//                 ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : const Text(
//                     'Confirm Booking',
//                     style: TextStyle(fontSize: 16),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../providers/service_provider.dart';
import '../../../providers/user_provider.dart';
import '../../utils/mock_data.dart';
import '../main_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final int workerId;
  final int serviceId;

  const BookingDetailsScreen({
    super.key,
    required this.workerId,
    required this.serviceId,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  String _timeSelectionMode = 'slot'; // 'slot' or 'manual'
  TimeOfDay? _manualStartTime;
  TimeOfDay? _manualEndTime;

  final List<String> _timeSlots = [
    '09:00 AM - 11:00 AM',
    '11:00 AM - 01:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
    '06:00 PM - 08:00 PM',
  ];

  // Hardcoded blocked slots for now (will be integrated with worker availability later)
  final List<String> _blockedSlots = [
    '11:00 AM - 01:00 PM',
    '06:00 PM - 08:00 PM',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _manualStartTime = picked;
        } else {
          _manualEndTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool _checkIfSlotBlocked(String slot) {
    return _blockedSlots.contains(slot);
  }

  bool _checkIfManualTimeBlocked() {
    if (_manualStartTime == null || _manualEndTime == null) return false;

    final manualSlot =
        '${_formatTimeOfDay(_manualStartTime!)} - ${_formatTimeOfDay(_manualEndTime!)}';

    // Check if manual time overlaps with any blocked slot
    for (var blockedSlot in _blockedSlots) {
      // This is a simple check - you can implement more sophisticated overlap detection
      if (manualSlot == blockedSlot) {
        return true;
      }
    }
    return false;
  }

  void _showTimeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Time'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Radio option for predefined slots
                    RadioListTile<String>(
                      title: const Text('Choose from time slots'),
                      value: 'slot',
                      groupValue: _timeSelectionMode,
                      onChanged: (value) {
                        setDialogState(() {
                          _timeSelectionMode = value!;
                          _manualStartTime = null;
                          _manualEndTime = null;
                        });
                      },
                    ),

                    // Show time slots if slot mode is selected
                    if (_timeSelectionMode == 'slot') ...[
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _timeSlots.length,
                          itemBuilder: (context, index) {
                            final slot = _timeSlots[index];
                            final isBlocked = _checkIfSlotBlocked(slot);
                            final isSelected = _selectedTimeSlot == slot;

                            return RadioListTile<String>(
                              title: Text(
                                slot,
                                style: TextStyle(
                                  color: isBlocked ? Colors.grey : null,
                                  decoration: isBlocked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: isBlocked
                                  ? const Text(
                                      'Already booked',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                              value: slot,
                              groupValue: _selectedTimeSlot,
                              onChanged: isBlocked
                                  ? null
                                  : (value) {
                                      setDialogState(() {
                                        _selectedTimeSlot = value;
                                      });
                                    },
                            );
                          },
                        ),
                      ),
                    ],

                    const Divider(),

                    // Radio option for manual time entry
                    RadioListTile<String>(
                      title: const Text('Enter time manually'),
                      value: 'manual',
                      groupValue: _timeSelectionMode,
                      onChanged: (value) {
                        setDialogState(() {
                          _timeSelectionMode = value!;
                          _selectedTimeSlot = null;
                        });
                      },
                    ),

                    // Show manual time pickers if manual mode is selected
                    if (_timeSelectionMode == 'manual') ...[
                      const SizedBox(height: 8),
                      ListTile(
                        title: const Text('Start Time'),
                        trailing: TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _selectTime(context, true);
                            _showTimeSelectionDialog();
                          },
                          child: Text(
                            _manualStartTime != null
                                ? _formatTimeOfDay(_manualStartTime!)
                                : 'Select',
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('End Time'),
                        trailing: TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _selectTime(context, false);
                            _showTimeSelectionDialog();
                          },
                          child: Text(
                            _manualEndTime != null
                                ? _formatTimeOfDay(_manualEndTime!)
                                : 'Select',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    bool isValid = false;

                    if (_timeSelectionMode == 'slot' &&
                        _selectedTimeSlot != null) {
                      if (_checkIfSlotBlocked(_selectedTimeSlot!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Service provider is already allocated for this time slot'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      isValid = true;
                    } else if (_timeSelectionMode == 'manual' &&
                        _manualStartTime != null &&
                        _manualEndTime != null) {
                      if (_checkIfManualTimeBlocked()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Service provider is already allocated for this time slot'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      isValid = true;
                    }

                    if (isValid) {
                      setState(() {
                        // Update the main state
                      });
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a valid time'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getSelectedTimeDisplay() {
    if (_timeSelectionMode == 'slot' && _selectedTimeSlot != null) {
      return _selectedTimeSlot!;
    } else if (_timeSelectionMode == 'manual' &&
        _manualStartTime != null &&
        _manualEndTime != null) {
      return '${_formatTimeOfDay(_manualStartTime!)} - ${_formatTimeOfDay(_manualEndTime!)}';
    }
    return 'Select time slot';
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_timeSelectionMode == 'slot' && _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_timeSelectionMode == 'manual' &&
        (_manualStartTime == null || _manualEndTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Final check for blocked slots
    if (_timeSelectionMode == 'slot' &&
        _checkIfSlotBlocked(_selectedTimeSlot!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Service provider is already allocated for this time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_timeSelectionMode == 'manual' && _checkIfManualTimeBlocked()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Service provider is already allocated for this time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);

      final service = serviceProvider.getServiceById(widget.serviceId);
      final currentUser = userProvider.currentUser;

      if (service == null || currentUser == null) {
        throw Exception('Service or user not found');
      }

      DateTime scheduledDate;

      if (_timeSelectionMode == 'slot') {
        // Parse time slot
        final timeStr = _selectedTimeSlot!.split(' - ')[0];
        final hour = int.parse(timeStr.split(':')[0]);
        final isPM = timeStr.contains('PM');
        scheduledDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          isPM && hour != 12 ? hour + 12 : hour,
        );
      } else {
        // Use manual time
        scheduledDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _manualStartTime!.hour,
          _manualStartTime!.minute,
        );
      }

      // Create booking
      await bookingProvider.createBooking(
        userId: currentUser.id!,
        workerId: widget.workerId,
        serviceId: widget.serviceId,
        scheduledDate: scheduledDate,
        totalAmount: service.basePrice,
      );

      if (!mounted) return;

      // Navigate to main screen with history tab
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final service = serviceProvider.getServiceById(widget.serviceId);
    final worker = MockDatabase.getWorkerById(widget.workerId);
    final workerUser =
        worker != null ? MockDatabase.getUserById(worker.userId) : null;
    final currentUser = userProvider.currentUser;
    final userLocation = currentUser != null
        ? MockDatabase.getUserLocation(currentUser.id!)
        : null;

    if (service == null || worker == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: Text('Service or worker not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Details',
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.build, color: theme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.serviceName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Base Price: ₹${service.basePrice.toStringAsFixed(0)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Worker Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Provider',
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              theme.primaryColor.withValues(alpha: 0.1),
                          backgroundImage: worker.profilePhoto != null
                              ? NetworkImage(worker.profilePhoto!)
                              : null,
                          child: worker.profilePhoto == null
                              ? Icon(Icons.person, color: theme.primaryColor)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workerUser?.name ?? 'Worker ${worker.id}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (worker.experienceYears != null)
                                Text(
                                  '${worker.experienceYears} years experience',
                                  style: theme.textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                        if (worker.isVerified)
                          Icon(Icons.verified, color: theme.primaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Date',
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: theme.primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? DateFormat('EEEE, MMMM dd, yyyy')
                                        .format(_selectedDate!)
                                    : 'Select a date',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Time Slot Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Time',
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _showTimeSelectionDialog,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: theme.primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getSelectedTimeDisplay(),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down,
                                color: theme.primaryColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location Card
            if (userLocation != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Location',
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: theme.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              userLocation.address,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Total Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.displaySmall,
                  ),
                  Text(
                    '₹${service.basePrice.toStringAsFixed(0)}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}