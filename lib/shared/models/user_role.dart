import 'package:casa_lazzarini/core/errors/app_exceptions.dart';

enum UserRole { user, superAdmin }

extension UserRoleX on UserRole {
  static UserRole fromDatabase(String value) {
    switch (value) {
      case 'user':
        return UserRole.user;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        throw AppException('Unknown UserRole database value: "$value"');
    }
  }

  String toDatabaseString() {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.superAdmin:
        return 'super_admin';
    }
  }
}
