enum UserRole {
  customer,
  worker,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'CUSTOMER';
      case UserRole.worker:
        return 'WORKER';
    }
  }

  String get description {
    switch (this) {
      case UserRole.customer:
        return 'Book home services';
      case UserRole.worker:
        return 'Provide services';
    }
  }
}