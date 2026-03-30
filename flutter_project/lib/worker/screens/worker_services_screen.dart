import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../customer/services/api_service.dart';
import '../../providers/worker_provider.dart';
import '../../theme/app_theme.dart';

class WorkerServicesScreen extends StatefulWidget {
  const WorkerServicesScreen({super.key});

  @override
  State<WorkerServicesScreen> createState() => _WorkerServicesScreenState();
}

class _WorkerServicesScreenState extends State<WorkerServicesScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _services = <Map<String, dynamic>>[];
  final Set<int> _selectedServiceIds = <int>{};

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.initialize();
      final result = await _apiService.getWorkerServicesSelection();

      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final rawServices = data['services'] as List<dynamic>? ?? <dynamic>[];

        final parsedServices = rawServices
            .whereType<Map<String, dynamic>>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        final selectedIds = <int>{};
        for (final service in parsedServices) {
          final id = (service['service_id'] as num?)?.toInt();
          final isSelected = service['is_selected'] == true;
          if (id != null && isSelected) {
            selectedIds.add(id);
          }
        }

        setState(() {
          _services = parsedServices;
          _selectedServiceIds
            ..clear()
            ..addAll(selectedIds);
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            (result['message']?.toString().trim().isNotEmpty ?? false)
                ? result['message'].toString()
                : 'Failed to load services';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load services: $e';
      });
    }
  }

  Future<void> _saveSelection() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _apiService.initialize();
      final result = await _apiService.updateWorkerServicesSelection(
        _selectedServiceIds.toList()..sort(),
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      if (result['success'] == true) {
        await context.read<WorkerProvider>().fetchWorkerProfile();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Services updated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
        return;
      }

      final message = (result['message']?.toString().trim().isNotEmpty ?? false)
          ? result['message'].toString()
          : 'Failed to update services';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update services: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupByCategory() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final service in _services) {
      final category = (service['category_name']?.toString().trim().isNotEmpty ?? false)
          ? service['category_name'].toString()
          : 'Other';
      grouped.putIfAbsent(category, () => <Map<String, dynamic>>[]).add(service);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.getTextColor(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services I Provide'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadServices,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 42),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadServices,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text(
                              'Select the services you want to provide. Customers can only find you for selected services.',
                              style: TextStyle(
                                color: AppTheme.getTextColor(context, secondary: true),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ..._groupByCategory().entries.map((entry) {
                              final category = entry.key;
                              final items = entry.value;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...items.map((service) {
                                    final serviceId = (service['service_id'] as num?)?.toInt();
                                    if (serviceId == null) {
                                      return const SizedBox.shrink();
                                    }
                                    final serviceName =
                                        (service['service_name'] ?? '').toString();
                                    final basePrice =
                                        ((service['base_price'] as num?) ?? 0).toDouble();

                                    return CheckboxListTile(
                                      value: _selectedServiceIds.contains(serviceId),
                                      title: Text(serviceName),
                                      subtitle: Text('Base price: Rs${basePrice.toStringAsFixed(0)}'),
                                      controlAffinity: ListTileControlAffinity.leading,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                                      onChanged: (checked) {
                                        setState(() {
                                          if (checked == true) {
                                            _selectedServiceIds.add(serviceId);
                                          } else {
                                            _selectedServiceIds.remove(serviceId);
                                          }
                                        });
                                      },
                                    );
                                  }),
                                  const Divider(height: 20),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveSelection,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              _isSaving ? 'Saving...' : 'Save Selected Services',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppTheme.workerPrimaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
