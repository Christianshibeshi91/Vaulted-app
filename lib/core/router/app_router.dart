import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/biometric_lock_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/mfa_challenge_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/verify_email_screen.dart';
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/onboarding/onboarding_first_card_screen.dart';
import '../../presentation/screens/onboarding/onboarding_profile_screen.dart';
import '../../presentation/screens/onboarding/onboarding_security_screen.dart';
import '../../presentation/screens/onboarding/onboarding_welcome_screen.dart';
import '../../presentation/screens/admin/admin_alerts_screen.dart';
import '../../presentation/screens/admin/admin_audit_log_screen.dart';
import '../../presentation/screens/admin/admin_cards_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_feature_flags_screen.dart';
import '../../presentation/screens/admin/admin_revenue_screen.dart';
import '../../presentation/screens/admin/admin_settings_screen.dart';
import '../../presentation/screens/admin/admin_transactions_screen.dart';
import '../../presentation/screens/admin/admin_user_detail_screen.dart';
import '../../presentation/screens/admin/admin_users_screen.dart';
import '../../presentation/screens/user/activity_screen.dart';
import '../../presentation/screens/user/card_detail_screen.dart';
import '../../presentation/screens/user/cards_list_screen.dart';
import '../../presentation/screens/user/dashboard_screen.dart';
import '../../presentation/screens/user/notifications_screen.dart';
import '../../presentation/screens/user/profile_screen.dart';
import '../../presentation/screens/user/security_settings_screen.dart';
import '../../presentation/shells/admin_shell.dart';
import '../../presentation/shells/user_shell.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'route_names.dart';

// ── Placeholder auth state (replace with real provider later) ───
final _isLoggedInProvider = StateProvider<bool>((_) => false);
final _isOnboardedProvider = StateProvider<bool>((_) => false);
final _isAdminProvider = StateProvider<bool>((_) => false);

/// Top-level router provider consumed by [MaterialApp.router].
final appRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(_isLoggedInProvider);
  final isOnboarded = ref.watch(_isOnboardedProvider);
  final isAdmin = ref.watch(_isAdminProvider);

  return GoRouter(
    initialLocation: RoutePaths.authWelcome,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final path = state.uri.path;
      final onAuthRoute = path.startsWith('/auth');
      final onOnboarding = path.startsWith('/onboarding');

      // Not authenticated and not on an auth screen -> welcome.
      if (!isLoggedIn && !onAuthRoute) {
        return RoutePaths.authWelcome;
      }

      // Authenticated but hasn't completed onboarding.
      if (isLoggedIn && !isOnboarded && !onOnboarding) {
        return RoutePaths.onboarding;
      }

      // Authenticated, onboarded, but still on an auth screen.
      if (isLoggedIn && isOnboarded && onAuthRoute) {
        return isAdmin ? RoutePaths.admin : RoutePaths.home;
      }

      return null; // no redirect
    },
    routes: [
      // ── Auth routes ─────────────────────────────────────────
      GoRoute(
        path: RoutePaths.authWelcome,
        name: RouteNames.authWelcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.authLogin,
        name: RouteNames.authLogin,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.authRegister,
        name: RouteNames.authRegister,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.authForgotPassword,
        name: RouteNames.authForgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.authVerifyEmail,
        name: RouteNames.authVerifyEmail,
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: RoutePaths.authMfaChallenge,
        name: RouteNames.authMfaChallenge,
        builder: (_, _) => const MfaChallengeScreen(),
      ),
      GoRoute(
        path: RoutePaths.authBiometricLock,
        name: RouteNames.authBiometricLock,
        builder: (_, _) => const BiometricLockScreen(),
      ),

      // ── Onboarding routes ───────────────────────────────────
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (_, _) => const OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingProfile,
        name: RouteNames.onboardingProfile,
        builder: (_, _) => const OnboardingProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingSecurity,
        name: RouteNames.onboardingSecurity,
        builder: (_, _) => const OnboardingSecurityScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingFirstCard,
        name: RouteNames.onboardingFirstCard,
        builder: (_, _) => const OnboardingFirstCardScreen(),
      ),

      // ── User shell (bottom nav) ────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            UserShell(navigationShell: navigationShell),
        branches: [
          // Tab 0 - Home (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (_, _) => const DashboardScreen(),
              ),
            ],
          ),

          // Tab 1 - Cards
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.cards,
                name: RouteNames.cards,
                builder: (_, _) => const CardsListScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.cardDetail,
                    name: RouteNames.cardDetail,
                    builder: (_, state) => CardDetailScreen(
                      cardId: state.pathParameters['cardId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.cardRedeem,
                    name: RouteNames.cardRedeem,
                    builder: (_, state) => _PlaceholderScreen(
                      title:
                          'Redeem ${state.pathParameters['cardId'] ?? ''}',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tab 2 - Activity
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.activity,
                name: RouteNames.activity,
                builder: (_, _) => const ActivityScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.activityDetail,
                    name: RouteNames.activityDetail,
                    builder: (_, state) => _PlaceholderScreen(
                      title:
                          'Transaction ${state.pathParameters['txId'] ?? ''}',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tab 3 - Notifications
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.notifications,
                name: RouteNames.notifications,
                builder: (_, _) => const NotificationsScreen(),
              ),
            ],
          ),

          // Tab 4 - Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.profileEdit,
                    name: RouteNames.profileEdit,
                    builder: (_, _) =>
                        const _PlaceholderScreen(title: 'Edit Profile'),
                  ),
                  GoRoute(
                    path: RoutePaths.profileSecurity,
                    name: RouteNames.profileSecurity,
                    builder: (_, _) => const SecuritySettingsScreen(),
                  ),
                  GoRoute(
                    path: RoutePaths.profileSupport,
                    name: RouteNames.profileSupport,
                    builder: (_, _) =>
                        const _PlaceholderScreen(title: 'Support'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Admin shell (drawer nav) ───────────────────────────
      ShellRoute(
        builder: (_, _, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.admin,
            name: RouteNames.admin,
            builder: (_, _) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.adminUsers,
            name: RouteNames.adminUsers,
            builder: (_, _) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: RoutePaths.adminUserDetail,
            name: RouteNames.adminUserDetail,
            builder: (_, state) => AdminUserDetailScreen(
              uid: state.pathParameters['uid'] ?? '',
            ),
          ),
          GoRoute(
            path: RoutePaths.adminTransactions,
            name: RouteNames.adminTransactions,
            builder: (_, _) => const AdminTransactionsScreen(),
          ),
          GoRoute(
            path: RoutePaths.adminCards,
            name: RouteNames.adminCards,
            builder: (_, _) => const AdminCardsScreen(),
          ),
          GoRoute(
            path: RoutePaths.adminAnalytics,
            name: RouteNames.adminAnalytics,
            builder: (_, _) => const AdminRevenueScreen(),
          ),
          GoRoute(
            path: RoutePaths.adminRevenue,
            name: RouteNames.adminRevenue,
            builder: (_, _) => const AdminRevenueScreen(),
          ),
          GoRoute(
            path: RoutePaths.adminFeatureFlags,
            name: RouteNames.adminFeatureFlags,
            builder: (_, _) => const AdminFeatureFlagsScreen(),
          ),
          GoRoute(
            path: RoutePaths.adminAlerts,
            name: RouteNames.adminAlerts,
            builder: (_, _) => const AdminAlertsScreen(),
          ),
          GoRoute(
            path: RoutePaths.adminAuditLog,
            name: RouteNames.adminAuditLog,
            builder: (_, _) => const AdminAuditLogScreen(),
          ),
          GoRoute(
            path: RoutePaths.adminSettings,
            name: RouteNames.adminSettings,
            builder: (_, _) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

// ── Placeholder screen ────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: VaultedTypography.gold(VaultedTypography.headlineLarge),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: VaultedTypography.muted(VaultedTypography.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
