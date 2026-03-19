class Payment {
  final int id;
  final int bookingId;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final DateTime? paidAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    this.paidAt,
  });

  Payment copyWith({
    int? id,
    int? bookingId,
    String? paymentMethod,
    String? paymentStatus,
    String? transactionId,
    DateTime? paidAt,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      transactionId: transactionId ?? this.transactionId,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
      'paid_at': paidAt?.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? 'pending',
      transactionId: json['transaction_id'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }

  @override
  String toString() => 'Payment(id: $id, bookingId: $bookingId, status: $paymentStatus)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
