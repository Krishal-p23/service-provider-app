import 'package:flutter/material.dart';
import '../models/job.dart';
import '../data/mock_job_data.dart';

enum JobFilter { day, week, month }

class JobProvider extends ChangeNotifier {
  Job? _activeJob;
  List<Job> _scheduledJobs = [];
  JobFilter _currentFilter = JobFilter.day;

  Job? get activeJob => _activeJob;
  List<Job> get scheduledJobs => _scheduledJobs;
  JobFilter get currentFilter => _currentFilter;

  JobProvider() {
    loadScheduledJobs();
  }

  void loadScheduledJobs() {
    switch (_currentFilter) {
      case JobFilter.day:
        _scheduledJobs = MockJobData.getTodayJobs();
        break;
      case JobFilter.week:
        _scheduledJobs = MockJobData.getWeekJobs();
        break;
      case JobFilter.month:
        _scheduledJobs = MockJobData.getMonthJobs();
        break;
    }
    
    // Sort by scheduled time
    _scheduledJobs.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    
    // Remove active job from scheduled jobs if it exists
    if (_activeJob != null) {
      _scheduledJobs.removeWhere((job) => job.id == _activeJob!.id);
    }
    
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