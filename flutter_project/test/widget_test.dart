import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/customer/models/booking.dart';
import 'package:flutter_project/customer/models/review.dart';
import 'package:flutter_project/customer/models/service.dart';
import 'package:flutter_project/customer/models/worker.dart';

void main() {
  group('Service model', () {
    test('fromJson converts numeric base_price to double', () {
      final service = Service.fromJson({
        'id': 3,
        'category_id': 2,
        'service_name': 'Deep Cleaning',
        'base_price': 499,
      });

      expect(service.id, 3);
      expect(service.categoryId, 2);
      expect(service.serviceName, 'Deep Cleaning');
      expect(service.basePrice, 499.0);
    });

    test('copyWith keeps id equality semantics', () {
      final original = Service(
        id: 9,
        categoryId: 2,
        serviceName: 'AC Service',
        basePrice: 799,
      );
      final updated = original.copyWith(serviceName: 'AC Full Service');

      expect(updated.serviceName, 'AC Full Service');
      expect(updated, original);
    });
  });

  group('Worker model', () {
    test('fromJson defaults optional booleans and IDs', () {
      final worker = Worker.fromJson({});

      expect(worker.id, 0);
      expect(worker.userId, 0);
      expect(worker.isVerified, false);
      expect(worker.isAvailable, true);
    });
  });

  group('Booking model', () {
    test('fromJson parses date fields including reschedule metadata', () {
      final booking = Booking.fromJson({
        'id': 44,
        'user_id': 1,
        'worker_id': 2,
        'service_id': 3,
        'scheduled_date': '2026-01-15T10:00:00Z',
        'status': 'confirmed',
        'total_amount': 1250,
        'created_at': '2026-01-01T08:00:00Z',
        'previous_scheduled_date': '2026-01-14T10:00:00Z',
        'rescheduled_at': '2026-01-10T09:00:00Z',
        'rescheduled_by': 'customer',
      });

      expect(booking.id, 44);
      expect(booking.totalAmount, 1250.0);
      expect(booking.status, 'confirmed');
      expect(booking.previousScheduledDate, isNotNull);
      expect(booking.rescheduledAt, isNotNull);
      expect(booking.rescheduledBy, 'customer');
    });
  });

  group('Review model', () {
    test('toJson/fromJson round-trip preserves key fields', () {
      final review = Review(
        id: 7,
        bookingId: 10,
        userId: 2,
        workerId: 5,
        rating: 4,
        comment: 'Great work',
      );

      final decoded = Review.fromJson(review.toJson());

      expect(decoded.id, review.id);
      expect(decoded.bookingId, review.bookingId);
      expect(decoded.workerId, review.workerId);
      expect(decoded.rating, 4);
      expect(decoded.comment, 'Great work');
    });
  });
}
