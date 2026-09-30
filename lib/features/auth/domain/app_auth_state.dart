import '../../../shared/models/profile.dart';
import '../../../shared/models/user_role.dart';

enum AppAuthStatus { loading, unauthenticated, authenticated }

class AppAuthState {
  final AppAuthStatus status;
  final Profile? profile;
  final String? errorMessage;

  const AppAuthState._({required this.status, this.profile, this.errorMessage});

  const AppAuthState.loading() : this._(status: AppAuthStatus.loading);

  const AppAuthState.unauthenticated()
    : this._(status: AppAuthStatus.unauthenticated);

  AppAuthState.unauthenticatedWithError(String message)
    : this._(status: AppAuthStatus.unauthenticated, errorMessage: message);

  AppAuthState.authenticated(Profile profile)
    : this._(status: AppAuthStatus.authenticated, profile: profile);

  bool get isLoading => status == AppAuthStatus.loading;
  bool get isAuthenticated => status == AppAuthStatus.authenticated;
  bool get isSuperAdmin => profile?.role == UserRole.superAdmin;
  bool get hasError => errorMessage != null;
}
