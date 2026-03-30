class Booking {
  final int id;
  final int userId;
  final int workerId;
  final int serviceId;
  final DateTime scheduledDate;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String? activationOtp;
  final DateTime? otpExpiresAt;
  final DateTime? previousScheduledDate;
  final DateTime? rescheduledAt;
  final String? rescheduledBy;
  final String? rescheduleReason;

  Booking({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceId,
    required this.scheduledDate,
    required this.status,
    required this.totalAmount,
    DateTime? createdAt,
    this.activationOtp,
    this.otpExpiresAt,
    this.previousScheduledDate,
    this.rescheduledAt,
    this.rescheduledBy,
    this.rescheduleReason,
  }) : createdAt = createdAt ?? DateTime.now();

  Booking copyWith({
    int? id,
    int? userId,
    int? workerId,
    int? serviceId,
    DateTime? scheduledDate,
    String? status,
    double? totalAmount,
    DateTime? createdAt,
    String? activationOtp,
    DateTime? otpExpiresAt,
    DateTime? previousScheduledDate,
    DateTime? rescheduledAt,
    String? rescheduledBy,
    String? rescheduleReason,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workerId: workerId ?? this.workerId,
      serviceId: serviceId ?? this.serviceId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      activationOtp: activationOtp ?? this.activationOtp,
      otpExpiresAt: otpExpiresAt ?? this.otpExpiresAt,
      previousScheduledDate: previousScheduledDate ?? this.previousScheduledDate,
      rescheduledAt: rescheduledAt ?? this.rescheduledAt,
      rescheduledBy: rescheduledBy ?? this.rescheduledBy,
      rescheduleReason: rescheduleReason ?? this.rescheduleReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'worker_id': workerId,
      'service_id': serviceId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'activation_otp': activationOtp,
      'otp_expires_at': otpExpiresAt?.toIso8601String(),
      'previous_scheduled_date': previousScheduledDate?.toIso8601String(),
      'rescheduled_at': rescheduledAt?.toIso8601String(),
      'rescheduled_by': rescheduledBy,
      'reschedule_reason': rescheduleReason,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      workerId: json['worker_id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      activationOtp: json['activation_otp']?.toString(),
      otpExpiresAt: json['otp_expires_at'] != null
          ? DateTime.parse(json['otp_expires_at'])
          : null,
        previousScheduledDate: json['previous_scheduled_date'] != null
          ? DateTime.parse(json['previous_scheduled_date'])
          : null,
        rescheduledAt: json['rescheduled_at'] != null
          ? DateTime.parse(json['rescheduled_at'])
          : null,
        rescheduledBy: json['rescheduled_by']?.toString(),
        rescheduleReason: json['reschedule_reason']?.toString(),
    );
  }

  @override
  String toString() =>
      'Booking(id: $id, status: $status, totalAmount: $totalAmount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
