
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../providers/service_provider.dart';
import '../../../providers/user_provider.dart';
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
  bool _isLoadingAvailability = false;
  String _timeSelectionMode = 'slot'; // 'slot' or 'manual'
  TimeOfDay? _manualStartTime;
  TimeOfDay? _manualEndTime;
  Set<int> _unavailableHours = <int>{};

  final List<String> _timeSlots = [
    '09:00 AM - 11:00 AM',
    '11:00 AM - 01:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
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
        _selectedTimeSlot = null;
        _manualStartTime = null;
        _manualEndTime = null;
      });
      await _loadWorkerAvailability(picked);
    }
  }

  Future<void> _loadWorkerAvailability(
    DateTime date, {
    bool showError = true,
  }) async {
    if (!mounted) return;

    setState(() {
      _isLoadingAvailability = true;
    });

    try {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      final unavailableHours = await bookingProvider.getWorkerUnavailableHours(
        workerId: widget.workerId,
        date: date,
      );

      if (!mounted) return;
      setState(() {
        _unavailableHours = unavailableHours;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _unavailableHours = <int>{};
      });
      if (showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load provider availability'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAvailability = false;
        });
      }
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

  int _timeTo24Hour(String timeText) {
    final parts = timeText.split(':');
    final hour12 = int.parse(parts[0]);
    final isPM = timeText.contains('PM');
    if (isPM && hour12 != 12) {
      return hour12 + 12;
    }
    if (!isPM && hour12 == 12) {
      return 0;
    }
    return hour12;
  }

  int _slotStartHour(String slot) {
    final start = slot.split(' - ').first;
    return _timeTo24Hour(start);
  }

  bool _isSlotUnavailable(String slot) {
    return _unavailableHours.contains(_slotStartHour(slot));
  }

  bool _isManualTimeUnavailable(TimeOfDay? startTime) {
    if (startTime == null) return false;
    return _unavailableHours.contains(startTime.hour);
  }

  DateTime _scheduledDateFromSlot(DateTime date, String slot) {
    final start = slot.split(' - ').first;
    final hour = _timeTo24Hour(start);
    return DateTime(date.year, date.month, date.day, hour);
  }

  void _showTimeSelectionDialog() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a date first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isLoadingAvailability) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading availability, please wait...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (bottomSheetContext) {
        String localTimeSelectionMode = _timeSelectionMode;
        String? localSelectedTimeSlot = _selectedTimeSlot;
        TimeOfDay? localManualStartTime = _manualStartTime;
        TimeOfDay? localManualEndTime = _manualEndTime;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: const Text('Choose from time slots'),
                    value: 'slot',
                    groupValue: localTimeSelectionMode,
                    onChanged: (value) {
                      setSheetState(() {
                        localTimeSelectionMode = value!;
                        localManualStartTime = null;
                        localManualEndTime = null;
                      });
                    },
                  ),
                  if (localTimeSelectionMode == 'slot')
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        itemCount: _timeSlots.length,
                        itemBuilder: (_, index) {
                          final slot = _timeSlots[index];
                          final isBlocked = _isSlotUnavailable(slot);

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
                                    'Not available',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                            value: slot,
                            groupValue: localSelectedTimeSlot,
                            onChanged: isBlocked
                                ? null
                                : (value) {
                                    setSheetState(() {
                                      localSelectedTimeSlot = value;
                                    });
                                  },
                          );
                        },
                      ),
                    ),
                  const Divider(),
                  RadioListTile<String>(
                    title: const Text('Enter time manually'),
                    value: 'manual',
                    groupValue: localTimeSelectionMode,
                    onChanged: (value) {
                      setSheetState(() {
                        localTimeSelectionMode = value!;
                        localSelectedTimeSlot = null;
                      });
                    },
                  ),
                  if (localTimeSelectionMode == 'manual') ...[
                    ListTile(
                      title: const Text('Start Time'),
                      trailing: TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime:
                                localManualStartTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              localManualStartTime = picked;
                            });
                          }
                        },
                        child: Text(
                          localManualStartTime != null
                              ? _formatTimeOfDay(localManualStartTime!)
                              : 'Select',
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('End Time'),
                      trailing: TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime:
                                localManualEndTime ??
                                localManualStartTime ??
                                TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              localManualEndTime = picked;
                            });
                          }
                        },
                        child: Text(
                          localManualEndTime != null
                              ? _formatTimeOfDay(localManualEndTime!)
                              : 'Select',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(bottomSheetContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            bool isValid = false;

                            if (localTimeSelectionMode == 'slot' &&
                                localSelectedTimeSlot != null) {
                              if (_isSlotUnavailable(localSelectedTimeSlot!)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'This time slot is not available',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              isValid = true;
                            } else if (localTimeSelectionMode == 'manual' &&
                                localManualStartTime != null &&
                                localManualEndTime != null) {
                              final isEndAfterStart =
                                  localManualEndTime!.hour * 60 +
                                      localManualEndTime!.minute >
                                  localManualStartTime!.hour * 60 +
                                      localManualStartTime!.minute;

                              if (!isEndAfterStart) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'End time should be after start time',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              if (_isManualTimeUnavailable(
                                localManualStartTime,
                              )) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('This time is not available'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              isValid = true;
                            }

                            if (isValid) {
                              setState(() {
                                _timeSelectionMode = localTimeSelectionMode;
                                _selectedTimeSlot = localSelectedTimeSlot;
                                _manualStartTime = localManualStartTime;
                                _manualEndTime = localManualEndTime;
                              });
                              Navigator.of(bottomSheetContext).pop();
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
                      ),
                    ],
                  ),
                ],
              ),
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

    if (_isLoadingAvailability) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading availability, please wait...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_timeSelectionMode == 'manual') {
      final isEndAfterStart =
          _manualEndTime!.hour * 60 + _manualEndTime!.minute >
          _manualStartTime!.hour * 60 + _manualStartTime!.minute;
      if (!isEndAfterStart) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time should be after start time'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    await _loadWorkerAvailability(_selectedDate!, showError: false);

    // Final conflict check before API call
    if (_timeSelectionMode == 'slot' &&
        _isSlotUnavailable(_selectedTimeSlot!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This time slot is not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_timeSelectionMode == 'manual' &&
        _isManualTimeUnavailable(_manualStartTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This time is not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final serviceProvider = Provider.of<ServiceProvider>(
        context,
        listen: false,
      );

      final service = serviceProvider.getServiceById(widget.serviceId);
      final currentUser = userProvider.currentUser;

      if (service == null || currentUser == null) {
        throw Exception('Service or user not found');
      }

      DateTime scheduledDate;

      if (_timeSelectionMode == 'slot') {
        scheduledDate = _scheduledDateFromSlot(
          _selectedDate!,
          _selectedTimeSlot!,
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
        userId: currentUser.id,
        workerId: widget.workerId,
        serviceId: widget.serviceId,
        scheduledDate: scheduledDate,
        totalAmount: service.basePrice,
      );

      if (!mounted) return;

      // Navigate to main screen with history tab
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
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

    final service = serviceProvider.getServiceById(widget.serviceId);
    final worker = serviceProvider.getWorkerById(widget.workerId);
    final workerUser = serviceProvider.getWorkerUserByWorkerId(widget.workerId);
    final userLocation = null;

    if (service == null || worker == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: Text('Service or worker not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
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
                          backgroundColor: theme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
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
                    Text('Select Date', style: theme.textTheme.displaySmall),
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
                            Icon(
                              Icons.calendar_today,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? DateFormat(
                                        'EEEE, MMMM dd, yyyy',
                                      ).format(_selectedDate!)
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
                    Text('Select Time', style: theme.textTheme.displaySmall),
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
                            Icon(
                              Icons.arrow_drop_down,
                              color: theme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(height: 8),
                      if (_isLoadingAvailability)
                        const Text(
                          'Checking availability...',
                          style: TextStyle(fontSize: 12),
                        )
                      else
                        Text(
                          _unavailableHours.isEmpty
                              ? 'All listed hours are currently available'
                              : 'Unavailable at: ${_unavailableHours.map((h) => h.toString().padLeft(2, '0')).join(':00, ')}:00',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
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
                  Text('Total Amount', style: theme.textTheme.displaySmall),
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
                : const Text('Confirm Booking', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
