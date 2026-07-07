import 'package:flutter/foundation.dart';
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
import '../../presentation/screens/user/auto_lock_screen.dart';
import '../../presentation/screens/user/card_detail_screen.dart';
import '../../presentation/screens/user/card_redeem_screen.dart';
import '../../presentation/screens/user/cards_list_screen.dart';
import '../../presentation/screens/user/dashboard_screen.dart';
import '../../presentation/screens/user/delete_account_screen.dart';
import '../../presentation/screens/user/edit_profile_screen.dart';
import '../../presentation/screens/user/notifications_screen.dart';
import '../../presentation/screens/user/profile_screen.dart';
import '../../presentation/screens/user/security_settings_screen.dart';
import '../../presentation/screens/user/support_screen.dart';
import '../../presentation/screens/user/transaction_detail_screen.dart';
import '../../presentation/screens/user/two_factor_screen.dart';
import '../../presentation/shells/admin_shell.dart';
import '../../presentation/shells/user_shell.dart';
import '../../presentation/providers/auth_providers.dart';
import 'page_transitions.dart';
import 'route_names.dart';

/// Top-level router provider consumed by [MaterialApp.router].
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isLoggedIn = authState.valueOrNull != null;
  final isOnboarded = ref.watch(isOnboardedProvider);
  final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

  return GoRouter(
    initialLocation: RoutePaths.authWelcome,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final path = state.uri.path;
      final onAuthRoute = path.startsWith('/auth');
      final onOnboarding = path.startsWith('/onboarding');
      final onAdminRoute = path.startsWith('/admin');

      // Not authenticated and not on an auth screen -> welcome.
      if (!isLoggedIn && !onAuthRoute) {
        return RoutePaths.authWelcome;
      }

      // Authenticated but hasn't completed onboarding.
      if (isLoggedIn && !isOnboarded && !onOnboarding) {
        return RoutePaths.onboarding;
      }

      // Authenticated, onboarded, but still on auth or onboarding screen.
      if (isLoggedIn && isOnboarded && (onAuthRoute || onOnboarding)) {
        return isAdmin ? RoutePaths.admin : RoutePaths.home;
      }

      // Non-admin users cannot access admin routes.
      if (isLoggedIn && onAdminRoute && !isAdmin) {
        return RoutePaths.home;
      }

      return null; // no redirect
    },
    routes: [
      // ── Auth routes (fade + slide-up transition) ─────────────
      GoRoute(
        path: RoutePaths.authWelcome,
        name: RouteNames.authWelcome,
        pageBuilder: (_, state) => VaultedPageTransitions.authTransition(
          key: state.pageKey,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.authLogin,
        name: RouteNames.authLogin,
        pageBuilder: (_, state) => VaultedPageTransitions.authTransition(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.authRegister,
        name: RouteNames.authRegister,
        pageBuilder: (_, state) => VaultedPageTransitions.authTransition(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.authForgotPassword,
        name: RouteNames.authForgotPassword,
        pageBuilder: (_, state) => VaultedPageTransitions.authTransition(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.authVerifyEmail,
        name: RouteNames.authVerifyEmail,
        pageBuilder: (_, state) => VaultedPageTransitions.authTransition(
          key: state.pageKey,
          child: const VerifyEmailScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.authMfaChallenge,
        name: RouteNames.authMfaChallenge,
        pageBuilder: (_, state) => VaultedPageTransitions.authTransition(
          key: state.pageKey,
          child: const MfaChallengeScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.authBiometricLock,
        name: RouteNames.authBiometricLock,
        pageBuilder: (_, state) => VaultedPageTransitions.authTransition(
          key: state.pageKey,
          child: const BiometricLockScreen(),
        ),
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
                    pageBuilder: (_, state) =>
                        VaultedPageTransitions.detailTransition(
                      key: state.pageKey,
                      child: CardDetailScreen(
                        cardId: state.pathParameters['cardId'] ?? '',
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.cardRedeem,
                    name: RouteNames.cardRedeem,
                    pageBuilder: (_, state) =>
                        VaultedPageTransitions.detailTransition(
                      key: state.pageKey,
                      child: CardRedeemScreen(
                        cardId: state.pathParameters['cardId'] ?? '',
                      ),
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
                    pageBuilder: (_, state) =>
                        VaultedPageTransitions.detailTransition(
                      key: state.pageKey,
                      child: TransactionDetailScreen(
                        txId: state.pathParameters['txId'] ?? '',
                      ),
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
                    pageBuilder: (_, state) =>
                        VaultedPageTransitions.detailTransition(
                      key: state.pageKey,
                      child: const EditProfileScreen(),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.profileSecurity,
                    name: RouteNames.profileSecurity,
                    pageBuilder: (_, state) =>
                        VaultedPageTransitions.detailTransition(
                      key: state.pageKey,
                      child: const SecuritySettingsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.profileTwoFactor,
                    name: RouteNames.profileTwoFactor,
                    pageBuilder: (_, state) =>
                        VaultedPageTransitions.detailTransition(
                      key: state.pageKey,
                      child: const TwoFactorScreen(),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.profileAutoLock,
                    name: RouteNames.profileAutoLock,
                    pageBuilder: (_, state) =>
                        VaultedPageTransitions.detailTransition(
                      key: state.pageKey,
                      child: const AutoLockScreen(),
                    ),
                  ),
                  GoRoute(
                    path: RoutePaths.profileSupport,
                    name: RouteNames.profileSupport,
                    pageBuilder: (_, state) =>
                        VaultedPageTransitions.detailTransition(
                      key: state.pageKey,
                      child: const SupportScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'delete-account',
                    name: 'profile-delete-account',
                    pageBuilder: (_, state) =>
                        VaultedPageTransitions.detailTransition(
                      key: state.pageKey,
                      child: const DeleteAccountScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Admin shell (bottom tab nav) ─────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AdminShell(navigationShell: navigationShell),
        branches: [
          // Tab 0 - HOME (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.admin,
                name: RouteNames.admin,
                builder: (_, _) => const AdminDashboardScreen(),
              ),
            ],
          ),

          // Tab 1 - USERS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.adminUsers,
                name: RouteNames.adminUsers,
                builder: (_, _) => const AdminUsersScreen(),
                routes: [
                  GoRoute(
                    path: ':uid',
                    name: RouteNames.adminUserDetail,
                    builder: (_, state) => AdminUserDetailScreen(
                      uid: state.pathParameters['uid'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tab 2 - CARDS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.adminCards,
                name: RouteNames.adminCards,
                builder: (_, _) => const AdminCardsScreen(),
              ),
            ],
          ),

          // Tab 3 - ACTIVITY (Transactions)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.adminTransactions,
                name: RouteNames.adminTransactions,
                builder: (_, _) => const AdminTransactionsScreen(),
              ),
            ],
          ),

          // Tab 4 - SETTINGS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.adminSettings,
                name: RouteNames.adminSettings,
                builder: (_, _) => const AdminSettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Admin standalone routes (drawer-only, outside tabs) ──
      GoRoute(
        path: RoutePaths.adminRevenue,
        name: RouteNames.adminRevenue,
        builder: (_, _) => const AdminRevenueScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminAnalytics,
        name: RouteNames.adminAnalytics,
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
    ],
  );
});
