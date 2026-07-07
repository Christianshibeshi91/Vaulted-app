import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/auth_providers.dart';
import 'mfa_setup_screen.dart';

/// Dedicated Two-Factor Authentication settings screen.
class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  int _selectedMethod = 0; // 0 = authenticator, 1 = sms, 2 = email

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(title: const Text('Two-Factor Authentication')),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: VaultedColors.accentGold),
        ),
        error: (_, _) => const Center(child: Text('Failed to load')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          final mfaEnabled = user.mfaEnabled;

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // ── Status hero card ──
              Padding(
                padding: const EdgeInsets.all(VaultedSpacing.xl),
                child: Container(
                  padding: const EdgeInsets.all(VaultedSpacing.xl),
                  decoration: BoxDecoration(
                    color: VaultedColors.bgCard,
                    borderRadius: VaultedRadii.brCard,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mfaEnabled
                              ? VaultedColors.success.withValues(alpha: 0.12)
                              : VaultedColors.bgInput,
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          size: 36,
                          color: mfaEnabled
                              ? VaultedColors.success
                              : VaultedColors.textMuted,
                        ),
                      ),
                      VaultedSpacing.gapLg,
                      Text(
                        mfaEnabled ? 'Protected' : 'Not Enabled',
                        style: VaultedTypography.headlineMedium.copyWith(
                          color: mfaEnabled
                              ? VaultedColors.success
                              : VaultedColors.textSecondary,
                        ),
                      ),
                      VaultedSpacing.gapXs,
                      Text(
                        mfaEnabled
                            ? 'Your account has an extra layer of security'
                            : 'Add an extra layer of security to your account',
                        style: VaultedTypography.bodyMedium.copyWith(
                          color: VaultedColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Authentication Methods ──
              _SectionLabel(title: 'AUTHENTICATION METHODS'),
              VaultedSpacing.gapSm,
              _MethodTile(
                icon: Icons.qr_code_rounded,
                title: 'Authenticator App',
                subtitle: 'Google Authenticator, Authy',
                badge: 'Recommended',
                isSelected: _selectedMethod == 0,
                onTap: () {
                  Haptics.selection();
                  setState(() => _selectedMethod = 0);
                },
              ),
              _MethodTile(
                icon: Icons.phone_android_rounded,
                title: 'SMS Verification',
                subtitle: 'Text message to your phone',
                badge: 'Less secure',
                badgeColor: VaultedColors.warning,
                isSelected: _selectedMethod == 1,
                onTap: () {
                  Haptics.selection();
                  setState(() => _selectedMethod = 1);
                },
              ),
              _MethodTile(
                icon: Icons.email_outlined,
                title: 'Email Verification',
                subtitle: 'Code sent to your email',
                isSelected: _selectedMethod == 2,
                onTap: () {
                  Haptics.selection();
                  setState(() => _selectedMethod = 2);
                },
              ),

              VaultedSpacing.gapXl,

              // ── Backup Options ──
              _SectionLabel(title: 'BACKUP OPTIONS'),
              VaultedSpacing.gapSm,
              _InfoTile(
                icon: Icons.key_rounded,
                title: 'Recovery Codes',
                subtitle: mfaEnabled ? '8 codes remaining' : 'Set up 2FA first',
                trailing: mfaEnabled
                    ? TextButton(
                        onPressed: () {
                          Haptics.mediumTap();
                          // Regenerate recovery codes
                        },
                        child: Text(
                          'Regenerate',
                          style: VaultedTypography.labelSmall.copyWith(
                            color: VaultedColors.accentGold,
                          ),
                        ),
                      )
                    : null,
              ),
              _InfoTile(
                icon: Icons.alternate_email_rounded,
                title: 'Backup Email',
                subtitle: _maskEmail(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                ),
              ),

              VaultedSpacing.gapXl,

              // ── Trusted Devices ──
              _SectionLabel(title: 'TRUSTED DEVICES'),
              VaultedSpacing.gapSm,
              _InfoTile(
                icon: Icons.phone_iphone_rounded,
                title: 'This device',
                subtitle: 'Currently active',
                leading: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: VaultedColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Haptics.lightTap();
                    // Navigate to manage trusted devices
                  },
                  splashColor: VaultedColors.accentGoldDim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VaultedSpacing.xl,
                      vertical: VaultedSpacing.md,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.devices_rounded,
                          color: VaultedColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: VaultedSpacing.lg),
                        Expanded(
                          child: Text(
                            'Manage trusted devices',
                            style: VaultedTypography.bodyLarge,
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
              ),

              VaultedSpacing.gapXl,

              // ── Info card ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                ),
                child: Container(
                  padding: const EdgeInsets.all(VaultedSpacing.lg),
                  decoration: BoxDecoration(
                    color: VaultedColors.accentGold.withValues(alpha: 0.08),
                    borderRadius: VaultedRadii.brCard,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: VaultedColors.accentGold,
                        size: 20,
                      ),
                      const SizedBox(width: VaultedSpacing.md),
                      Expanded(
                        child: Text(
                          'We recommend using an authenticator app for the strongest protection.',
                          style: VaultedTypography.labelSmall.copyWith(
                            color: VaultedColors.accentGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              VaultedSpacing.gapXxl,

              // ── CTA ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Haptics.mediumTap();
                      if (mfaEnabled) {
                        _showDisableMfaSheet(context);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MfaSetupScreen(),
                          ),
                        );
                      }
                    },
                    child: Text(
                      mfaEnabled
                          ? 'Disable Two-Factor'
                          : 'Enable Two-Factor Authentication',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '—';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final masked = name.length > 2
        ? '${name.substring(0, 2)}${'•' * (name.length - 2)}'
        : name;
    return '$masked@${parts[1]}';
  }

  void _showDisableMfaSheet(BuildContext context) {
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
              Icons.warning_rounded,
              color: VaultedColors.warning,
              size: 48,
            ),
            VaultedSpacing.gapLg,
            Text(
              'Disable Two-Factor?',
              style: VaultedTypography.headlineMedium,
            ),
            VaultedSpacing.gapSm,
            Text(
              'This will make your account less secure. You can re-enable it anytime.',
              style: VaultedTypography.bodyMedium.copyWith(
                color: VaultedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            VaultedSpacing.gapXxl,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultedColors.danger,
                ),
                onPressed: () async {
                  Haptics.warning();
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .update({'mfaEnabled': false});
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Disable'),
              ),
            ),
            VaultedSpacing.gapMd,
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ──
class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VaultedSpacing.xl,
        VaultedSpacing.lg,
        VaultedSpacing.xl,
        0,
      ),
      child: Text(
        title,
        style: VaultedTypography.labelSmall.copyWith(
          color: VaultedColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Method selection tile ──
class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final Color badgeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.badgeColor = VaultedColors.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: VaultedColors.accentGoldDim,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: VaultedSpacing.xl,
            vertical: VaultedSpacing.md,
          ),
          color: isSelected
              ? VaultedColors.accentGold.withValues(alpha: 0.06)
              : null,
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? VaultedColors.accentGold
                    : VaultedColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: VaultedSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: VaultedTypography.bodyLarge),
                        if (badge != null) ...[
                          const SizedBox(width: VaultedSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: VaultedSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              borderRadius: VaultedRadii.brPill,
                            ),
                            child: Text(
                              badge!,
                              style: VaultedTypography.labelSmall.copyWith(
                                color: badgeColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: VaultedTypography.labelSmall.copyWith(
                        color: VaultedColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? VaultedColors.accentGold
                    : VaultedColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Info tile ──
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? leading;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VaultedSpacing.xl,
        vertical: VaultedSpacing.sm,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: VaultedSpacing.sm),
          ],
          Icon(icon, color: VaultedColors.textSecondary, size: 22),
          const SizedBox(width: VaultedSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: VaultedTypography.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: VaultedTypography.labelSmall.copyWith(
                    color: VaultedColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
