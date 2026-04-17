import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/customer/models/payment.dart';
import 'package:flutter_project/customer/models/service_category.dart';
import 'package:flutter_project/customer/models/user.dart';
import 'package:flutter_project/customer/models/user_location.dart';
import 'package:flutter_project/customer/models/wallet_transaction.dart';
import 'package:flutter_project/customer/models/worker_service.dart';
import 'package:flutter_project/worker/models/job.dart';

void main() {
  group('ServiceCategory', () {
    test('fromJson and toJson map fields correctly', () {
      final model = ServiceCategory.fromJson({
        'id': 1,
        'category_name': 'Plumbing',
        'icon_name': 'plumb',
      });

      expect(model.id, 1);
      expect(model.categoryName, 'Plumbing');
      expect(model.iconName, 'plumb');
      expect(model.toJson()['category_name'], 'Plumbing');
    });

    test('copyWith and equality by id', () {
      final base = ServiceCategory(id: 2, categoryName: 'AC');
      final changed = base.copyWith(categoryName: 'AC Repair');
      final unchanged = base.copyWith();

      expect(changed.categoryName, 'AC Repair');
      expect(changed, base);
      expect(changed.hashCode, base.hashCode);
      expect(unchanged.iconName, base.iconName);
      expect(base == base, true);
    });
  });

  group('Payment', () {
    test('fromJson parses paid_at and defaults status', () {
      final withDate = Payment.fromJson({
        'id': 10,
        'booking_id': 20,
        'payment_method': 'upi',
        'payment_status': 'paid',
        'transaction_id': 'txn_1',
        'paid_at': '2026-01-01T10:00:00Z',
      });

      final defaults = Payment.fromJson({});

      expect(withDate.paidAt, isNotNull);
      expect(withDate.paymentStatus, 'paid');
      expect(defaults.paymentStatus, 'pending');
      expect(defaults.id, 0);
    });

    test('toJson/copyWith/equality', () {
      final payment = Payment(
        id: 5,
        bookingId: 8,
        paymentMethod: 'card',
        paymentStatus: 'pending',
      );
      final updated = payment.copyWith(paymentStatus: 'paid');
      final unchanged = payment.copyWith();

      expect(updated.paymentStatus, 'paid');
      expect(updated, payment);
      expect(updated.toJson()['booking_id'], 8);
      expect(unchanged.paymentMethod, payment.paymentMethod);
      expect(payment == payment, true);
    });
  });

  group('WalletTransaction', () {
    test('fromJson defaults and amount conversion', () {
      final model = WalletTransaction.fromJson({'amount': 90, 'id': 1});
      final fallback = WalletTransaction.fromJson({});

      expect(model.amount, 90.0);
      expect(fallback.type, 'credit');
      expect(fallback.description, '');
    });

    test('copyWith and equality', () {
      final tx = WalletTransaction(
        id: 11,
        userId: 7,
        amount: 99,
        type: 'debit',
        description: 'test',
      );
      final changed = tx.copyWith(description: 'updated');
      final unchanged = tx.copyWith();

      expect(changed.description, 'updated');
      expect(changed, tx);
      expect(changed.toJson()['type'], 'debit');
      expect(unchanged.userId, tx.userId);
      expect(tx == tx, true);
    });
  });

  group('User', () {
    test('fromJson resolves phone fallback keys', () {
      final byMobile = User.fromJson({
        'id': 1,
        'name': 'A',
        'email': 'a@x.com',
        'mobile': '12345',
        'role': 'USER',
      });

      final byPhoneNumber = User.fromJson({
        'id': 2,
        'name': 'B',
        'email': 'b@x.com',
        'phone_number': '67890',
      });

      expect(byMobile.phone, '12345');
      expect(byPhoneNumber.phone, '67890');
      expect(byPhoneNumber.role, 'USER');
    });

    test('copyWith, toJson and equality', () {
      final user = User(
        id: 3,
        name: 'User',
        email: 'u@x.com',
        phone: '111',
        passwordHash: 'ph',
        role: 'WORKER',
      );
      final changed = user.copyWith(name: 'Updated');
      final unchanged = user.copyWith();

      expect(changed.name, 'Updated');
      expect(changed.toJson()['password_hash'], 'ph');
      expect(changed, user);
      expect(unchanged.role, user.role);
      expect(user == user, true);
    });
  });

  group('UserLocation', () {
    test('fromJson defaults and numeric conversion', () {
      final model = UserLocation.fromJson({
        'id': 1,
        'user_id': 3,
        'latitude': 12,
        'longitude': 77.1,
        'address': 'X',
      });

      expect(model.latitude, 12.0);
      expect(model.longitude, 77.1);
      expect(model.toJson()['user_id'], 3);
    });

    test('copyWith and equality', () {
      final location = UserLocation(
        id: 9,
        userId: 1,
        latitude: 1,
        longitude: 2,
        address: 'A',
      );

      final changed = location.copyWith(address: 'B');
      final unchanged = location.copyWith();
      expect(changed.address, 'B');
      expect(changed, location);
      expect(unchanged.latitude, location.latitude);
      expect(location == location, true);
    });
  });

  group('WorkerService', () {
    test('fromJson parses nullable override and defaults', () {
      final withOverride = WorkerService.fromJson({
        'id': 1,
        'worker_id': 2,
        'service_id': 3,
        'price_override': 450,
      });
      final withoutOverride = WorkerService.fromJson({});

      expect(withOverride.priceOverride, 450.0);
      expect(withoutOverride.priceOverride, isNull);
      expect(withoutOverride.workerId, 0);
    });

    test('copyWith/toJson/equality', () {
      final base = WorkerService(id: 4, workerId: 8, serviceId: 10);
      final changed = base.copyWith(priceOverride: 500);
      final unchanged = base.copyWith();

      expect(changed.priceOverride, 500);
      expect(changed.toJson()['service_id'], 10);
      expect(changed, base);
      expect(unchanged.workerId, base.workerId);
      expect(base == base, true);
    });
  });

  group('Job', () {
    test('constructor assigns all fields', () {
      final job = Job(
        id: 'j1',
        title: 'Fix AC',
        customerName: 'Riya',
        address: 'Street 1',
        customerLatitude: 12.0,
        customerLongitude: 77.0,
        customerDistanceKm: 4.2,
        scheduledTime: DateTime.parse('2026-01-01T10:00:00Z'),
        duration: '1h',
        status: 'pending',
        amount: 899,
        description: 'Service desc',
      );

      expect(job.id, 'j1');
      expect(job.customerName, 'Riya');
      expect(job.customerDistanceKm, 4.2);
      expect(job.amount, 899);
    });
  });
}
