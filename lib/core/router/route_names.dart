/// Centralised route path constants.
///
/// Using constants prevents typo-driven 404s and makes
/// refactoring paths a single-point change.
abstract final class RoutePaths {
  // ── Auth ──────────────────────────────────────────────────────
  static const authWelcome = '/auth/welcome';
  static const authLogin = '/auth/login';
  static const authRegister = '/auth/register';
  static const authForgotPassword = '/auth/forgot-password';
  static const authVerifyEmail = '/auth/verify-email';
  static const authMfaChallenge = '/auth/mfa-challenge';
  static const authBiometricLock = '/auth/biometric-lock';

  // ── Onboarding ────────────────────────────────────────────────
  static const onboarding = '/onboarding';
  static const onboardingProfile = '/onboarding/profile';
  static const onboardingSecurity = '/onboarding/security';
  static const onboardingFirstCard = '/onboarding/first-card';

  // ── User (bottom-nav tabs) ────────────────────────────────────
  static const home = '/home';
  static const cards = '/cards';
  static const cardDetail = 'detail/:cardId';
  static const cardRedeem = 'redeem/:cardId';
  static const activity = '/activity';
  static const activityDetail = 'detail/:txId';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const profileEdit = 'edit';
  static const profileSecurity = 'security';
  static const profileSupport = 'support';

  // ── Admin ─────────────────────────────────────────────────────
  static const admin = '/admin';
  static const adminUsers = '/admin/users';
  static const adminUserDetail = '/admin/users/:uid';
  static const adminTransactions = '/admin/transactions';
  static const adminCards = '/admin/cards';
  static const adminAnalytics = '/admin/analytics';
  static const adminSettings = '/admin/settings';
}

/// Named route identifiers for [GoRouter.goNamed].
abstract final class RouteNames {
  // Auth
  static const authWelcome = 'auth-welcome';
  static const authLogin = 'auth-login';
  static const authRegister = 'auth-register';
  static const authForgotPassword = 'auth-forgot-password';
  static const authVerifyEmail = 'auth-verify-email';
  static const authMfaChallenge = 'auth-mfa-challenge';
  static const authBiometricLock = 'auth-biometric-lock';

  // Onboarding
  static const onboarding = 'onboarding';
  static const onboardingProfile = 'onboarding-profile';
  static const onboardingSecurity = 'onboarding-security';
  static const onboardingFirstCard = 'onboarding-first-card';

  // User tabs
  static const home = 'home';
  static const cards = 'cards';
  static const cardDetail = 'card-detail';
  static const cardRedeem = 'card-redeem';
  static const activity = 'activity';
  static const activityDetail = 'activity-detail';
  static const notifications = 'notifications';
  static const profile = 'profile';
  static const profileEdit = 'profile-edit';
  static const profileSecurity = 'profile-security';
  static const profileSupport = 'profile-support';

  // Admin
  static const admin = 'admin-dashboard';
  static const adminUsers = 'admin-users';
  static const adminUserDetail = 'admin-user-detail';
  static const adminTransactions = 'admin-transactions';
  static const adminCards = 'admin-cards';
  static const adminAnalytics = 'admin-analytics';
  static const adminSettings = 'admin-settings';
}
