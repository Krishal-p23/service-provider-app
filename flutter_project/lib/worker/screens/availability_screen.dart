import 'package:flutter/material.dart';
import '../../customer/services/api_service.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _availability = List.generate(7, (index) {
    return {
      'day_of_week': index,
      'is_available': false,
      'start_time': '09:00',
      'end_time': '18:00',
    };
  });

  static const _dayLabels = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoading = true);
    await _apiService.initialize();
    final result = await _apiService.getWorkerAvailabilitySchedule();

    if (result['success'] == true) {
      final items = (result['data'] as List<dynamic>?) ?? <dynamic>[];
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final day = (item['day_of_week'] as num?)?.toInt() ?? -1;
        if (day < 0 || day > 6) continue;
        _availability[day] = {
          'day_of_week': day,
          'is_available': item['is_available'] == true,
          'start_time': (item['start_time']?.toString() ?? '09:00').substring(
            0,
            5,
          ),
          'end_time': (item['end_time']?.toString() ?? '18:00').substring(0, 5),
        };
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _pickTime(int day, String key) async {
    final current = _availability[day][key] as String;
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 9,
      minute: int.tryParse(parts.last) ?? 0,
    );

    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (selected == null) return;

    final hh = selected.hour.toString().padLeft(2, '0');
    final mm = selected.minute.toString().padLeft(2, '0');
    setState(() {
      _availability[day][key] = '$hh:$mm';
    });
  }

  Future<void> _saveAvailability() async {
    setState(() => _isSaving = true);
    await _apiService.initialize();
    final result = await _apiService.saveWorkerAvailabilitySchedule(
      _availability,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Availability updated successfully')),
      );
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to save availability')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Availability')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final dayItem = _availability[index];
                final isAvailable = dayItem['is_available'] == true;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_dayLabels[index]),
                          value: isAvailable,
                          onChanged: (value) {
                            setState(() {
                              dayItem['is_available'] = value;
                            });
                          },
                        ),
                        if (isAvailable)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _pickTime(index, 'start_time'),
                                  child: Text(
                                    'Start: ${dayItem['start_time']}',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _pickTime(index, 'end_time'),
                                  child: Text('End: ${dayItem['end_time']}'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: 7,
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveAvailability,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Availability'),
          ),
        ),
      ),
    );
  }
}
