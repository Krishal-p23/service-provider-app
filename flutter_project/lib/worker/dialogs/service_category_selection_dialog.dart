import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../customer/providers/service_provider.dart';
import '../../customer/services/api_service.dart';

class ServiceCategorySelectionDialog extends StatefulWidget {
  final String serviceName;
  final double basePrice;
  final String? customerName;
  final int bookingId;

  const ServiceCategorySelectionDialog({
    super.key,
    required this.serviceName,
    required this.basePrice,
    this.customerName,
    required this.bookingId,
  });

  @override
  State<ServiceCategorySelectionDialog> createState() =>
      _ServiceCategorySelectionDialogState();
}

class _ServiceCategorySelectionDialogState
    extends State<ServiceCategorySelectionDialog> {
  final ApiService _apiService = ApiService();

  late double _totalAmount;
  final Map<int, bool> _selectedServices = {};
  List<Map<String, dynamic>> _categoryServices = [];
  String? _categoryName;
  int? _bookedServiceId;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _totalAmount = widget.basePrice;
    _loadCompletionServices();
  }

  Future<void> _loadCompletionServices() async {
    try {
      await _apiService.initialize();

      final bookingResult = await _apiService.getBookingById(widget.bookingId);
      final workerServicesResult = await _apiService
          .getWorkerServicesSelection();

      final bookingData = bookingResult['data'] as Map<String, dynamic>?;
      final bookedServiceId = (bookingData?['service_id'] as num?)?.toInt();

      final allWorkerServices =
          (workerServicesResult['data']?['services'] as List<dynamic>? ??
                  const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

      final bookedService = allWorkerServices.firstWhere(
        (service) =>
            (service['service_id'] as num?)?.toInt() == bookedServiceId,
        orElse: () {
          final fallback = allWorkerServices.where((service) {
            final serviceName =
                (service['service_name']?.toString().trim().toLowerCase() ??
                '');
            return serviceName == widget.serviceName.trim().toLowerCase();
          });
          return fallback.isNotEmpty ? fallback.first : <String, dynamic>{};
        },
      );

      final bookedCategoryId = (bookedService['category_id'] as num?)?.toInt();

      final sameCategoryServices = allWorkerServices.where((service) {
        final serviceCategoryId = (service['category_id'] as num?)?.toInt();
        return bookedCategoryId != null &&
            serviceCategoryId == bookedCategoryId;
      }).toList();

      final additionalServices = sameCategoryServices.where((service) {
        final serviceId = (service['service_id'] as num?)?.toInt();
        return serviceId != null && serviceId != bookedServiceId;
      }).toList();

      final serviceProvider = Provider.of<ServiceProvider>(
        context,
        listen: false,
      );

      setState(() {
        _bookedServiceId = bookedServiceId;
        _categoryName =
            bookedService['category_name']?.toString() ??
            serviceProvider
                .getCategoryById(bookedCategoryId ?? -1)
                ?.categoryName;
        _categoryServices = additionalServices;
        _selectedServices.clear();
        for (final service in additionalServices) {
          final serviceId = (service['service_id'] as num?)?.toInt();
          if (serviceId != null) {
            _selectedServices[serviceId] = false;
          }
        }
        _recalculateTotal();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = 'Failed to load services for this booking.';
        _isLoading = false;
      });
    }
  }

  double _servicePrice(Map<String, dynamic> service) {
    final priceOverride = (service['price_override'] as num?)?.toDouble();
    if (priceOverride != null && priceOverride > 0) {
      return priceOverride;
    }
    return (service['base_price'] as num?)?.toDouble() ?? 0;
  }

  void _recalculateTotal() {
    var extrasTotal = 0.0;
    for (final service in _categoryServices) {
      final serviceId = (service['service_id'] as num?)?.toInt();
      if (serviceId == null) {
        continue;
      }
      if (_selectedServices[serviceId] == true) {
        extrasTotal += _servicePrice(service);
      }
    }
    _totalAmount = widget.basePrice + extrasTotal;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return AlertDialog(
        title: const Text('Service Confirmation'),
        content: const Center(child: CircularProgressIndicator()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Service Confirmation'),
      titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Info Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Booking #${widget.bookingId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Service: ${widget.serviceName}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (widget.customerName != null &&
                      widget.customerName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Customer: ${widget.customerName}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Service selection section
            Text(
              _categoryName == null
                  ? 'Services Completed'
                  : 'Services Completed ($_categoryName)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Base service (mandatory)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '₹${widget.basePrice.toStringAsFixed(0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            if (_loadError != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _loadError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                  ),
                ),
              )
            else if (_categoryServices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'No additional services found in this category. Base price will be used.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              )
            else
              Column(
                children: _categoryServices.map((service) {
                  return _buildServiceCheckbox(service: service);
                }).toList(),
              ),

            const SizedBox(height: 16),

            // Total Amount Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${_totalAmount.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Info Text
            Text(
              'Select all additional services completed by the worker. Total payable is mandatory base amount + selected service prices.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _totalAmount),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text(
            'Confirm & Show QR',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCheckbox({required Map<String, dynamic> service}) {
    final serviceId = (service['service_id'] as num?)?.toInt();
    if (serviceId == null) {
      return const SizedBox.shrink();
    }

    final name = service['service_name']?.toString() ?? 'Service';
    final price = _servicePrice(service);

    return CheckboxListTile(
      value: _selectedServices[serviceId] ?? false,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedServices[serviceId] = value;
            _recalculateTotal();
          });
        }
      },
      title: Text(name),
      subtitle: Text('₹${price.toStringAsFixed(0)}'),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }
}
