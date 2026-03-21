import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/auth_providers.dart';
import 'data_export_screen.dart';
import 'notification_prefs_screen.dart';


/// Profile screen with grouped settings sections.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: userAsync.when(
        loading: () => const _ProfileSkeleton(),
        error: (_, _) => const Center(
          child: Text('Failed to load profile'),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Not signed in'),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    VaultedSpacing.xl,
                    VaultedSpacing.xxl,
                    VaultedSpacing.xl,
                    VaultedSpacing.section,
                  ),
                  child: Column(
                    children: [
                      // Avatar with glow ring
                      GestureDetector(
                        onTap: () {
                          Haptics.lightTap();
                          // Image picker for avatar change
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: VaultedColors.accentGold.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: VaultedColors.accentGold.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: VaultedColors.accentGold,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: VaultedColors.bgCard,
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(
                                      _initials(user.displayName, user.email),
                                      style: VaultedTypography.gold(
                                        VaultedTypography.headlineLarge,
                                      ).copyWith(fontSize: 28),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      VaultedSpacing.gapLg,

                      // Name
                      Text(
                        user.displayName ?? 'Vaulted User',
                        style: VaultedTypography.headlineLarge,
                      ),
                      VaultedSpacing.gapXs,

                      // Email
                      Text(
                        user.email,
                        style: VaultedTypography.bodyMedium,
                      ),
                      VaultedSpacing.gapMd,

                      // Plan badge + member since
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: VaultedColors.accentGoldDim,
                              borderRadius: VaultedRadii.brPill,
                              border: Border.all(
                                color: VaultedColors.accentGold
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              user.plan.toUpperCase(),
                              style: VaultedTypography.labelSmall.copyWith(
                                color: VaultedColors.accentGold,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          if (user.createdAt != null) ...[
                            const SizedBox(width: VaultedSpacing.md),
                            Text(
                              'Member since ${Formatters.monthYear(user.createdAt!)}',
                              style: VaultedTypography.labelSmall,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Account section
              _SectionHeader(title: 'Account'),
              _SettingsTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () => context.go('/profile/edit'),
              ),
              _SettingsTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                onTap: () {
                  Haptics.lightTap();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationPrefsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: VaultedSpacing.lg),

              // Security section
              _SectionHeader(title: 'Security'),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                onTap: () => context.go('/profile/security'),
              ),
              _SettingsTile(
                icon: Icons.security_rounded,
                title: 'Two-Factor Authentication',
                trailing: _StatusIndicator(
                  enabled: user.mfaEnabled,
                ),
                onTap: () => context.go('/profile/security'),
              ),
              _SettingsTile(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Unlock',
                trailing: Switch(
                  value: user.biometricEnabled,
                  onChanged: (value) {
                    Haptics.toggle();
                    // Toggle biometric in Firestore
                  },
                ),
                onTap: null,
              ),
              _SettingsTile(
                icon: Icons.timer_outlined,
                title: 'Auto-Lock',
                trailing: Text(
                  _autoLockLabel(user.autoLockMinutes),
                  style: VaultedTypography.bodyMedium,
                ),
                onTap: () => context.go('/profile/security'),
              ),
              _SettingsTile(
                icon: Icons.devices_rounded,
                title: 'Active Sessions',
                onTap: () => context.go('/profile/security'),
              ),

              const SizedBox(height: VaultedSpacing.lg),

              // Data section
              _SectionHeader(title: 'Data'),
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'Export Data',
                onTap: () {
                  Haptics.lightTap();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DataExportScreen(),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete Account',
                titleColor: VaultedColors.danger,
                onTap: () {
                  Haptics.warning();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DataExportScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: VaultedSpacing.lg),

              // About section
              _SectionHeader(title: 'About'),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Version',
                trailing: Text(
                  '1.0.0',
                  style: VaultedTypography.bodyMedium,
                ),
                onTap: null,
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => _launchUrl(context, AppConstants.termsUrl),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _launchUrl(context, AppConstants.privacyUrl),
              ),
              _SettingsTile(
                icon: Icons.headset_mic_outlined,
                title: 'Support',
                onTap: () => context.go('/profile/support'),
              ),

              // Sign out
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  VaultedSpacing.xl,
                  VaultedSpacing.section,
                  VaultedSpacing.xl,
                  VaultedSpacing.lg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VaultedColors.danger,
                      side: BorderSide(
                        color: VaultedColors.danger.withValues(alpha: 0.3),
                      ),
                      backgroundColor: VaultedColors.danger.withValues(alpha: 0.06),
                    ),
                    onPressed: () => _confirmSignOut(context),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign Out'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _initials(String? name, String email) {
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    Haptics.lightTap();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  String _autoLockLabel(int minutes) => switch (minutes) {
        0 => 'Never',
        1 => '1 min',
        _ => '$minutes min',
      };

  void _confirmSignOut(BuildContext context) {
    Haptics.warning();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VaultedColors.bgSecondary,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: VaultedSpacing.bottomSheet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: VaultedColors.danger,
              size: 40,
            ),
            VaultedSpacing.gapLg,
            Text('Sign Out?', style: VaultedTypography.headlineMedium),
            VaultedSpacing.gapSm,
            Text(
              'You will need to sign in again to access your vault.',
              style: VaultedTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            VaultedSpacing.gapXxl,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultedColors.danger,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Haptics.heavyTap();
                  Navigator.pop(ctx);
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text('Sign Out'),
              ),
            ),
            VaultedSpacing.gapMd,
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Section header ------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VaultedSpacing.xl,
        VaultedSpacing.lg,
        VaultedSpacing.xl,
        VaultedSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: VaultedColors.accentGold.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: VaultedSpacing.sm),
          Text(
            title.toUpperCase(),
            style: VaultedTypography.labelSmall.copyWith(
              color: VaultedColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Settings tile -------------------------------------------------------

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null
            ? () {
                Haptics.lightTap();
                onTap!();
              }
            : null,
        splashColor: VaultedColors.accentGoldDim,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VaultedSpacing.xl,
            vertical: VaultedSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: titleColor ?? VaultedColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: VaultedSpacing.lg),
              Expanded(
                child: Text(
                  title,
                  style: VaultedTypography.bodyLarge.copyWith(
                    color: titleColor,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
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

// -- Status indicator (on/off) -------------------------------------------

class _StatusIndicator extends StatelessWidget {
  final bool enabled;
  const _StatusIndicator({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: enabled
            ? VaultedColors.success.withValues(alpha: 0.12)
            : VaultedColors.bgInput,
        borderRadius: VaultedRadii.brPill,
      ),
      child: Text(
        enabled ? 'ON' : 'OFF',
        style: VaultedTypography.labelSmall.copyWith(
          color: enabled ? VaultedColors.success : VaultedColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// -- Profile skeleton ----------------------------------------------------

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: VaultedColors.shimmerBase,
      highlightColor: VaultedColors.shimmerHighlight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(VaultedSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: VaultedSpacing.xxl),
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: VaultedColors.bgCard,
                  shape: BoxShape.circle,
                ),
              ),
              VaultedSpacing.gapLg,
              Container(
                width: 150,
                height: 20,
                decoration: BoxDecoration(
                  color: VaultedColors.bgCard,
                  borderRadius: VaultedRadii.brBadge,
                ),
              ),
              VaultedSpacing.gapSm,
              Container(
                width: 200,
                height: 14,
                decoration: BoxDecoration(
                  color: VaultedColors.bgCard,
                  borderRadius: VaultedRadii.brBadge,
                ),
              ),
              VaultedSpacing.gapXxl,
              ...List.generate(
                6,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: VaultedSpacing.lg),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: VaultedColors.bgCard,
                      borderRadius: VaultedRadii.brButton,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

