enum UserRole {
  customer,
  worker,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.worker:
        return 'Worker';
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