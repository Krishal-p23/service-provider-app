/// Service model - maps to 'services' table in database
/// Represents individual services that workers can offer
class Service {
  final int id;
  final int categoryId; // Foreign key to service_categories.id
  final String serviceName;
  final double basePrice;

  Service({
    required this.id,
    required this.categoryId,
    required this.serviceName,
    required this.basePrice,
  });

  Service copyWith({
    int? id,
    int? categoryId,
    String? serviceName,
    double? basePrice,
  }) {
    return Service(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      serviceName: serviceName ?? this.serviceName,
      basePrice: basePrice ?? this.basePrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'service_name': serviceName,
      'base_price': basePrice,
    };
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      basePrice: json['base_price'] != null 
          ? (json['base_price'] as num).toDouble() 
          : 0.0,
    );
  }

  @override
  String toString() => 'Service(id: $id, serviceName: $serviceName, basePrice: $basePrice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Service && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}