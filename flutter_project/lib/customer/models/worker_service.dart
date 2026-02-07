class WorkerService {
  final int id;
  final int workerId;
  final int serviceId;
  final double? priceOverride;

  WorkerService({
    required this.id,
    required this.workerId,
    required this.serviceId,
    this.priceOverride,
  });

  WorkerService copyWith({
    int? id,
    int? workerId,
    int? serviceId,
    double? priceOverride,
  }) {
    return WorkerService(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      serviceId: serviceId ?? this.serviceId,
      priceOverride: priceOverride ?? this.priceOverride,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'service_id': serviceId,
      'price_override': priceOverride,
    };
  }

  factory WorkerService.fromJson(Map<String, dynamic> json) {
    return WorkerService(
      id: json['id'] ?? 0,
      workerId: json['worker_id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      priceOverride: json['price_override'] != null ? (json['price_override'] as num).toDouble() : null,
    );
  }

  @override
  String toString() => 'WorkerService(id: $id, workerId: $workerId, serviceId: $serviceId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkerService && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
