class Review {
  final int id;
  final int bookingId;
  final int userId;
  final int workerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.workerId,
    required this.rating,
    this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Review copyWith({
    int? id,
    int? bookingId,
    int? userId,
    int? workerId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      workerId: workerId ?? this.workerId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'worker_id': workerId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      workerId: json['worker_id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  @override
  String toString() => 'Review(id: $id, workerId: $workerId, rating: $rating)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
