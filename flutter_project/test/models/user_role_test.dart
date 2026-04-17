import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/customer/models/user_role.dart';

void main() {
  test('UserRole display names are correct', () {
    expect(UserRole.customer.displayName, 'Customer');
    expect(UserRole.worker.displayName, 'Worker');
  });

  test('UserRole descriptions are correct', () {
    expect(UserRole.customer.description, 'Book home services');
    expect(UserRole.worker.description, 'Provide services');
  });
}
