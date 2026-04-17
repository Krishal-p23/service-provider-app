import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/customer/models/booking.dart';
import 'package:flutter_project/customer/models/review.dart';
import 'package:flutter_project/customer/models/service.dart';
import 'package:flutter_project/customer/models/worker.dart';

void main() {
  group('Service high coverage', () {
    test('constructor, copyWith, toJson, toString, equality/hashCode', () {
      final service = Service(
        id: 1,
        categoryId: 2,
        serviceName: 'Cleaning',
        basePrice: 350,
      );

      final copied = service.copyWith(
        id: 3,
        categoryId: 4,
        serviceName: 'Deep Cleaning',
        basePrice: 499,
      );
      final unchanged = service.copyWith();

      expect(copied.id, 3);
      expect(copied.categoryId, 4);
      expect(copied.serviceName, 'Deep Cleaning');
      expect(copied.basePrice, 499);
      expect(copied.toJson(), {
        'id': 3,
        'category_id': 4,
        'service_name': 'Deep Cleaning',
        'base_price': 499.0,
      });
      expect(copied.toString(), contains('Service('));
      expect(
        Service(id: 1, categoryId: 9, serviceName: 'X', basePrice: 1),
        service,
      );
      expect(
        Service(id: 1, categoryId: 1, serviceName: 'a', basePrice: 1).hashCode,
        service.hashCode,
      );
      expect(unchanged.categoryId, service.categoryId);
      expect(service == service, true);
    });

    test('fromJson full and fallback paths', () {
      final full = Service.fromJson({
        'id': 10,
        'category_id': 20,
        'service_name': 'AC Repair',
        'base_price': 999,
      });

      final fallback = Service.fromJson({});

      expect(full.basePrice, 999.0);
      expect(fallback.id, 0);
      expect(fallback.categoryId, 0);
      expect(fallback.serviceName, '');
      expect(fallback.basePrice, 0.0);
    });
  });

  group('Worker high coverage', () {
    test('constructor and utility methods', () {
      final worker = Worker(
        id: 11,
        userId: 22,
        isVerified: true,
        isAvailable: false,
        experienceYears: 6,
        bio: 'Expert worker',
        profilePhoto: 'photo.png',
      );

      final copied = worker.copyWith(
        id: 12,
        userId: 24,
        isVerified: false,
        isAvailable: true,
        experienceYears: 7,
        bio: 'Updated',
        profilePhoto: 'x.png',
      );
      final unchanged = worker.copyWith();

      expect(copied.id, 12);
      expect(copied.isAvailable, true);
      expect(copied.toJson()['profile_photo'], 'x.png');
      expect(copied.toString(), contains('Worker('));
      expect(Worker(id: 11, userId: 999), worker);
      expect(Worker(id: 11, userId: 123).hashCode, worker.hashCode);
      expect(unchanged.bio, worker.bio);
      expect(worker == worker, true);
    });

    test('fromJson full and fallback paths', () {
      final full = Worker.fromJson({
        'id': 1,
        'user_id': 2,
        'is_verified': true,
        'is_available': false,
        'experience_years': 5,
        'bio': 'Bio',
        'profile_photo': 'a.jpg',
      });

      final fallback = Worker.fromJson({});

      expect(full.isVerified, true);
      expect(full.isAvailable, false);
      expect(fallback.isVerified, false);
      expect(fallback.isAvailable, true);
      expect(fallback.experienceYears, isNull);
    });
  });

  group('Booking high coverage', () {
    test('toJson/copyWith/equality/hashCode and full optional fields', () {
      final booking = Booking(
        id: 1,
        userId: 2,
        workerId: 3,
        serviceId: 4,
        scheduledDate: DateTime.parse('2026-01-01T10:00:00Z'),
        status: 'pending',
        totalAmount: 500,
        createdAt: DateTime.parse('2026-01-01T09:00:00Z'),
        activationOtp: '123456',
        otpExpiresAt: DateTime.parse('2026-01-01T10:10:00Z'),
        previousScheduledDate: DateTime.parse('2025-12-31T10:00:00Z'),
        rescheduledAt: DateTime.parse('2025-12-31T09:00:00Z'),
        rescheduledBy: 'customer',
        rescheduleReason: 'Busy',
      );

      final copied = booking.copyWith(
        id: 9,
        userId: 8,
        workerId: 7,
        serviceId: 6,
        scheduledDate: DateTime.parse('2026-01-02T10:00:00Z'),
        status: 'confirmed',
        totalAmount: 900,
        createdAt: DateTime.parse('2026-01-02T09:00:00Z'),
        activationOtp: '000000',
        otpExpiresAt: DateTime.parse('2026-01-02T10:10:00Z'),
        previousScheduledDate: DateTime.parse('2026-01-01T10:00:00Z'),
        rescheduledAt: DateTime.parse('2026-01-01T09:00:00Z'),
        rescheduledBy: 'worker',
        rescheduleReason: 'Delay',
      );
      final unchanged = booking.copyWith();

      expect(copied.id, 9);
      expect(copied.status, 'confirmed');
      expect(copied.toJson()['rescheduled_by'], 'worker');
      expect(copied.toString(), contains('Booking('));
      expect(
        Booking(
          id: 1,
          userId: 0,
          workerId: 0,
          serviceId: 0,
          scheduledDate: DateTime.now(),
          status: 'pending',
          totalAmount: 0,
        ),
        booking,
      );
      expect(
        Booking(
          id: 1,
          userId: 1,
          workerId: 1,
          serviceId: 1,
          scheduledDate: DateTime.now(),
          status: 'pending',
          totalAmount: 1,
        ).hashCode,
        booking.hashCode,
      );
      expect(unchanged.activationOtp, booking.activationOtp);
      expect(booking == booking, true);
    });

    test('fromJson full and fallback paths', () {
      final full = Booking.fromJson({
        'id': 20,
        'user_id': 10,
        'worker_id': 11,
        'service_id': 12,
        'scheduled_date': '2026-01-03T10:00:00Z',
        'status': 'completed',
        'total_amount': 1400,
        'created_at': '2026-01-02T10:00:00Z',
        'activation_otp': '222222',
        'otp_expires_at': '2026-01-03T10:30:00Z',
        'previous_scheduled_date': '2026-01-02T10:00:00Z',
        'rescheduled_at': '2026-01-02T09:00:00Z',
        'rescheduled_by': 'admin',
        'reschedule_reason': 'Weather',
      });

      final fallback = Booking.fromJson({});

      expect(full.totalAmount, 1400.0);
      expect(full.otpExpiresAt, isNotNull);
      expect(full.previousScheduledDate, isNotNull);
      expect(full.rescheduledAt, isNotNull);
      expect(full.rescheduledBy, 'admin');
      expect(fallback.status, 'pending');
      expect(fallback.activationOtp, isNull);
      expect(fallback.otpExpiresAt, isNull);
      expect(fallback.previousScheduledDate, isNull);
      expect(fallback.rescheduledAt, isNull);
      expect(fallback.rescheduledBy, isNull);
      expect(fallback.rescheduleReason, isNull);
    });
  });

  group('Review high coverage', () {
    test('copyWith/toJson/toString/equality/hashCode', () {
      final review = Review(
        id: 1,
        bookingId: 2,
        userId: 3,
        workerId: 4,
        rating: 5,
        comment: 'Excellent',
        createdAt: DateTime.parse('2026-01-01T10:00:00Z'),
      );

      final copied = review.copyWith(
        id: 7,
        bookingId: 8,
        userId: 9,
        workerId: 10,
        rating: 4,
        comment: 'Good',
        createdAt: DateTime.parse('2026-01-02T10:00:00Z'),
      );
      final unchanged = review.copyWith();

      expect(copied.id, 7);
      expect(copied.toJson()['rating'], 4);
      expect(copied.toString(), contains('Review('));
      expect(
        Review(id: 1, bookingId: 0, userId: 0, workerId: 0, rating: 1),
        review,
      );
      expect(
        Review(id: 1, bookingId: 1, userId: 1, workerId: 1, rating: 2).hashCode,
        review.hashCode,
      );
      expect(unchanged.comment, review.comment);
      expect(review == review, true);
    });

    test('fromJson full and fallback paths', () {
      final full = Review.fromJson({
        'id': 11,
        'booking_id': 21,
        'user_id': 31,
        'worker_id': 41,
        'rating': 5,
        'comment': 'Nice',
        'created_at': '2026-01-01T10:00:00Z',
      });

      final fallback = Review.fromJson({});

      expect(full.comment, 'Nice');
      expect(full.createdAt, isNotNull);
      expect(fallback.id, 0);
      expect(fallback.rating, 0);
      expect(fallback.comment, isNull);
    });
  });
}
