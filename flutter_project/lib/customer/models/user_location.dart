class UserLocation {
  final int id;
  final int userId;
  final double latitude;
  final double longitude;
  final String address;

  UserLocation({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  UserLocation copyWith({
    int? id,
    int? userId,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return UserLocation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserLocation(id: $id, userId: $userId, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
