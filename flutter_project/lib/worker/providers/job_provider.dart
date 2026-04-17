import 'package:flutter/material.dart';
import '../models/job.dart';
import 'package:flutter_project/customer/services/api_service.dart';

enum JobFilter { day, week, month }

class JobProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Job? _activeJob;
  List<Job> _scheduledJobs = [];
  JobFilter _currentFilter = JobFilter.day;
  bool _isLoading = false;
  String? _error;

  Job? get activeJob => _activeJob;
  List<Job> get scheduledJobs => _scheduledJobs;
  JobFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  JobProvider() {
    loadScheduledJobs();
  }

  /// Convert API filter string to JobFilter enum
  String _filterToString(JobFilter filter) {
    switch (filter) {
      case JobFilter.day:
        return 'day';
      case JobFilter.week:
        return 'week';
      case JobFilter.month:
        return 'month';
    }
  }

  /// Convert API job data to Job model
  Job _jobFromApi(Map<String, dynamic> data) {
    try {
      final scheduledTime = DateTime.parse(
        data['scheduled_time'] ?? DateTime.now().toIso8601String(),
      );

      return Job(
        id: data['job_id']?.toString() ?? '',
        title: data['service_name'] ?? 'Service',
        customerName: data['customer_name'] ?? 'Unknown',
        address: data['address'] ?? '',
        customerLatitude: (data['customer_latitude'] as num?)?.toDouble(),
        customerLongitude: (data['customer_longitude'] as num?)?.toDouble(),
        customerDistanceKm: (data['customer_distance_km'] as num?)?.toDouble(),
        scheduledTime: scheduledTime,
        duration: data['duration'] ?? '1 hour',
        status: data['status'] ?? 'Upcoming',
        amount: (data['amount'] ?? 0).toDouble(),
        description: data['description'] ?? data['category_name'] ?? '',
      );
    } catch (e) {
      throw Exception('Failed to parse job: $e');
    }
  }

  /// Load jobs from API
  Future<void> loadScheduledJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final filterStr = _filterToString(_currentFilter);
      final result = await _apiService.getWorkerJobs(filter: filterStr);

      if (result['success']) {
        final data = result['data'];
        final jobsList = data['jobs'] ?? [];

        _scheduledJobs = (jobsList as List)
            .whereType<Map<String, dynamic>>()
            .map(_jobFromApi)
            .toList();

        // Sort by scheduled time
        _scheduledJobs.sort(
          (a, b) => a.scheduledTime.compareTo(b.scheduledTime),
        );
        _activeJob = null;

        _error = null;
      } else {
        _error = result['data']?['error'] ?? 'Failed to load jobs';
        _scheduledJobs = [];
      }
    } catch (e) {
      _error = 'Error loading jobs: $e';
      _scheduledJobs = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(JobFilter filter) {
    _currentFilter = filter;
    loadScheduledJobs();
  }

  Future<bool> activateJob(Job job) async {
    _activeJob = job;
    _scheduledJobs.removeWhere((j) => j.id == job.id);
    notifyListeners();
    return true;
  }

  Future<bool> deleteJob(String jobId) async {
    var existed = false;
    if (_activeJob?.id == jobId) {
      _activeJob = null;
      existed = true;
    }
    final before = _scheduledJobs.length;
    _scheduledJobs.removeWhere((job) => job.id == jobId);
    if (_scheduledJobs.length != before) existed = true;
    if (existed) notifyListeners();
    return existed;
  }

  Future<bool> rescheduleJob(String jobId, DateTime newTime) async {
    // Find the job in scheduled jobs
    final jobIndex = _scheduledJobs.indexWhere((job) => job.id == jobId);

    if (jobIndex != -1) {
      final job = _scheduledJobs[jobIndex];
      final updatedJob = Job(
        id: job.id,
        title: job.title,
        customerName: job.customerName,
        address: job.address,
        customerLatitude: job.customerLatitude,
        customerLongitude: job.customerLongitude,
        customerDistanceKm: job.customerDistanceKm,
        scheduledTime: newTime,
        duration: job.duration,
        status: job.status,
        amount: job.amount,
        description: job.description,
      );
      _scheduledJobs[jobIndex] = updatedJob;
      _scheduledJobs.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      notifyListeners();
      return true;
    } else if (_activeJob?.id == jobId) {
      // If rescheduling the active job, move it back to scheduled
      final updatedJob = Job(
        id: _activeJob!.id,
        title: _activeJob!.title,
        customerName: _activeJob!.customerName,
        address: _activeJob!.address,
        customerLatitude: _activeJob!.customerLatitude,
        customerLongitude: _activeJob!.customerLongitude,
        customerDistanceKm: _activeJob!.customerDistanceKm,
        scheduledTime: newTime,
        duration: _activeJob!.duration,
        status: _activeJob!.status,
        amount: _activeJob!.amount,
        description: _activeJob!.description,
      );
      _activeJob = null;
      _scheduledJobs.add(updatedJob);
      _scheduledJobs.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      notifyListeners();
      return true;
    }
    return false;
  }

  Job? getTopJob() {
    if (_scheduledJobs.isEmpty) return null;
    return _scheduledJobs.first;
  }
}
