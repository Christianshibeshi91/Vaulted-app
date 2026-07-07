import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_providers.dart';
import 'active_sessions_screen.dart';
import 'connected_accounts_screen.dart';

/// Security settings: password change, MFA, biometric, auto-lock, sessions.
class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(title: const Text('Security')),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: VaultedColors.accentGold),
        ),
        error: (_, _) => const Center(child: Text('Failed to load')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // Change Password
              _SectionTitle(title: 'Password'),
              _ActionTile(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => _showChangePasswordSheet(context),
              ),

              VaultedSpacing.gapLg,

              // Two-Factor Authentication → own screen
              _SectionTitle(title: 'Authentication'),
              _ActionTile(
                icon: Icons.shield_rounded,
                title: 'Two-Factor Authentication',
                subtitle: user.mfaEnabled
                    ? 'Enabled — Authenticator app'
                    : 'Add an extra layer of security',
                onTap: () => context.goNamed(RouteNames.profileTwoFactor),
              ),

              VaultedSpacing.gapLg,

              // Auto-Lock → own screen
              _SectionTitle(title: 'App Protection'),
              _ActionTile(
                icon: Icons.lock_clock_rounded,
                title: 'Auto-Lock',
                subtitle: _autoLockLabel(user.autoLockMinutes),
                onTap: () => context.goNamed(RouteNames.profileAutoLock),
              ),

              VaultedSpacing.gapLg,

              // Sessions
              _SectionTitle(title: 'Sessions & Accounts'),
              _ActionTile(
                icon: Icons.devices_rounded,
                title: 'Active Sessions',
                subtitle: 'Manage your logged-in devices',
                onTap: () {
                  Haptics.lightTap();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ActiveSessionsScreen(),
                    ),
                  );
                },
              ),
              _ActionTile(
                icon: Icons.link_rounded,
                title: 'Connected Accounts',
                subtitle: 'Google, Apple sign-in',
                onTap: () {
                  Haptics.lightTap();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ConnectedAccountsScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _autoLockLabel(int minutes) => switch (minutes) {
        0 => 'Never',
        1 => '1 minute',
        _ => '$minutes minutes',
      };

  void _showChangePasswordSheet(BuildContext context) {
    Haptics.mediumTap();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VaultedColors.bgSecondary,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          VaultedSpacing.xl,
          VaultedSpacing.md,
          VaultedSpacing.xl,
          MediaQuery.of(ctx).viewInsets.bottom + VaultedSpacing.xxxl,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Password',
                  style: VaultedTypography.headlineMedium),
              VaultedSpacing.gapXl,
              TextFormField(
                controller: currentCtrl,
                obscureText: true,
                validator: (v) => Validators.required(v, 'Current password'),
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              VaultedSpacing.gapLg,
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                validator: Validators.password,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_rounded),
                ),
              ),
              VaultedSpacing.gapLg,
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                validator: (v) => Validators.confirmPassword(v, newCtrl.text),
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_rounded),
                ),
              ),
              VaultedSpacing.gapXxl,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Haptics.success();
                      Navigator.pop(ctx);
                      // Perform password change via Firebase
                    }
                  },
                  child: const Text('Update Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// -- Reusable section title ----------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VaultedSpacing.xl,
        VaultedSpacing.lg,
        VaultedSpacing.xl,
        VaultedSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: VaultedTypography.labelSmall.copyWith(
          color: VaultedColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// -- Action tile (chevron) -----------------------------------------------

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Haptics.lightTap();
          onTap();
        },
        splashColor: VaultedColors.accentGoldDim,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VaultedSpacing.xl,
            vertical: VaultedSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: VaultedColors.textSecondary, size: 22),
              const SizedBox(width: VaultedSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: VaultedTypography.bodyLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: VaultedTypography.bodyMedium),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: VaultedColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

