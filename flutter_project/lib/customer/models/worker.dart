/// Worker model - matches database schema from workers table
class Worker {
  final int id;
  final int userId;  // Foreign key to users table
  final bool isVerified;
  final bool isAvailable;
  final int? experienceYears;
  final String? bio;
  final String? profilePhoto;

  Worker({
    required this.id,
    required this.userId,
    this.isVerified = false,
    this.isAvailable = true,
    this.experienceYears,
    this.bio,
    this.profilePhoto,
  });

  Worker copyWith({
    int? id,
    int? userId,
    bool? isVerified,
    bool? isAvailable,
    int? experienceYears,
    String? bio,
    String? profilePhoto,
  }) {
    return Worker(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'experience_years': experienceYears,
      'bio': bio,
      'profile_photo': profilePhoto,
    };
  }

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isAvailable: json['is_available'] ?? true,
      experienceYears: json['experience_years'],
      bio: json['bio'],
      profilePhoto: json['profile_photo'],
    );
  }

  @override
  String toString() {
    return 'Worker(id: $id, userId: $userId, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Worker && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}