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

/// Dedicated Auto-Lock settings screen with timer, method, and behavior options.
class AutoLockScreen extends ConsumerStatefulWidget {
  const AutoLockScreen({super.key});

  @override
  ConsumerState<AutoLockScreen> createState() => _AutoLockScreenState();
}

class _AutoLockScreenState extends ConsumerState<AutoLockScreen> {
  bool _autoLockEnabled = true;
  int _selectedTimer = 5;
  int _selectedMethod = 0; // 0 = biometric, 1 = pin, 2 = both
  bool _lockOnAppSwitch = true;
  bool _lockOnScreenOff = true;
  bool _requireOnTransactions = false;

  @override
  void initState() {
    super.initState();
    // Load user preferences after first build
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreferences());
  }

  void _loadPreferences() {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      setState(() {
        _selectedTimer = user.autoLockMinutes;
        _autoLockEnabled = user.autoLockMinutes > 0;
      });
    }
  }

  Future<void> _saveTimer(int minutes) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'autoLockMinutes': minutes});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(title: const Text('Auto-Lock')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // ── Master toggle card ──
          Padding(
            padding: const EdgeInsets.all(VaultedSpacing.xl),
            child: Container(
              padding: const EdgeInsets.all(VaultedSpacing.xl),
              decoration: BoxDecoration(
                color: VaultedColors.bgCard,
                borderRadius: VaultedRadii.brCard,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _autoLockEnabled
                          ? VaultedColors.accentGold.withValues(alpha: 0.12)
                          : VaultedColors.bgInput,
                    ),
                    child: Icon(
                      Icons.lock_clock_rounded,
                      size: 24,
                      color: _autoLockEnabled
                          ? VaultedColors.accentGold
                          : VaultedColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: VaultedSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enable Auto-Lock',
                            style: VaultedTypography.bodyLarge),
                        const SizedBox(height: 2),
                        Text(
                          'Automatically lock app after inactivity',
                          style: VaultedTypography.labelSmall.copyWith(
                            color: VaultedColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _autoLockEnabled,
                    onChanged: (value) {
                      Haptics.toggle();
                      setState(() => _autoLockEnabled = value);
                      _saveTimer(value ? _selectedTimer : 0);
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Lock Timer ──
          if (_autoLockEnabled) ...[
            _SectionLabel(title: 'LOCK TIMER'),
            VaultedSpacing.gapSm,
            ..._timerOptions.map((opt) => _TimerOption(
                  label: opt.label,
                  badge: opt.badge,
                  isSelected: _selectedTimer == opt.minutes,
                  onTap: () {
                    Haptics.selection();
                    setState(() => _selectedTimer = opt.minutes);
                    _saveTimer(opt.minutes);
                  },
                )),

            VaultedSpacing.gapXl,

            // ── Lock Method ──
            _SectionLabel(title: 'LOCK METHOD'),
            VaultedSpacing.gapSm,
            _MethodCard(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric',
              subtitle: 'Fingerprint or face unlock',
              isSelected: _selectedMethod == 0,
              onTap: () {
                Haptics.selection();
                setState(() => _selectedMethod = 0);
              },
            ),
            _MethodCard(
              icon: Icons.pin_rounded,
              title: 'PIN Code',
              subtitle: '4-digit security PIN',
              isSelected: _selectedMethod == 1,
              onTap: () {
                Haptics.selection();
                setState(() => _selectedMethod = 1);
              },
            ),
            _MethodCard(
              icon: Icons.verified_user_rounded,
              title: 'Both',
              subtitle: 'Biometric + PIN',
              badge: 'Most Secure',
              isSelected: _selectedMethod == 2,
              onTap: () {
                Haptics.selection();
                setState(() => _selectedMethod = 2);
              },
            ),

            VaultedSpacing.gapXl,

            // ── Behavior ──
            _SectionLabel(title: 'BEHAVIOR'),
            VaultedSpacing.gapSm,
            _BehaviorToggle(
              icon: Icons.swap_horiz_rounded,
              title: 'Lock on app switch',
              subtitle: 'Lock when switching to another app',
              value: _lockOnAppSwitch,
              onChanged: (v) {
                Haptics.toggle();
                setState(() => _lockOnAppSwitch = v);
              },
            ),
            _BehaviorToggle(
              icon: Icons.screen_lock_portrait_rounded,
              title: 'Lock on screen off',
              subtitle: 'Lock when device screen turns off',
              value: _lockOnScreenOff,
              onChanged: (v) {
                Haptics.toggle();
                setState(() => _lockOnScreenOff = v);
              },
            ),
            _BehaviorToggle(
              icon: Icons.payment_rounded,
              title: 'Require on transactions',
              subtitle: 'Require unlock before any transaction',
              value: _requireOnTransactions,
              onChanged: (v) {
                Haptics.toggle();
                setState(() => _requireOnTransactions = v);
              },
            ),

            VaultedSpacing.gapXl,

            // ── Info card ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
              child: Container(
                padding: const EdgeInsets.all(VaultedSpacing.lg),
                decoration: BoxDecoration(
                  color: VaultedColors.accentGold.withValues(alpha: 0.08),
                  borderRadius: VaultedRadii.brCard,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: VaultedColors.accentGold, size: 20),
                    const SizedBox(width: VaultedSpacing.md),
                    Expanded(
                      child: Text(
                        'Auto-lock protects your account if you leave your device unattended.',
                        style: VaultedTypography.labelSmall.copyWith(
                          color: VaultedColors.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Timer data ──
class _TimerData {
  final int minutes;
  final String label;
  final String? badge;
  const _TimerData(this.minutes, this.label, [this.badge]);
}

const _timerOptions = [
  _TimerData(1, 'Immediately'),
  _TimerData(1, '1 minute'),
  _TimerData(5, '5 minutes', 'Recommended'),
  _TimerData(15, '15 minutes'),
  _TimerData(30, '30 minutes'),
];

// ── Section label ──
class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VaultedSpacing.xl, VaultedSpacing.lg, VaultedSpacing.xl, 0,
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

// ── Timer option row ──
class _TimerOption extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimerOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
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
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? VaultedColors.accentGold
                    : VaultedColors.textMuted,
                size: 22,
              ),
              const SizedBox(width: VaultedSpacing.lg),
              Expanded(
                child: Text(label, style: VaultedTypography.bodyLarge),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VaultedSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: VaultedColors.accentGold.withValues(alpha: 0.15),
                    borderRadius: VaultedRadii.brPill,
                  ),
                  child: Text(
                    badge!,
                    style: VaultedTypography.labelSmall.copyWith(
                      color: VaultedColors.accentGold,
                      fontSize: 10,
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

// ── Lock method card ──
class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.badge,
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
              Icon(icon,
                  color: isSelected
                      ? VaultedColors.accentGold
                      : VaultedColors.textSecondary,
                  size: 22),
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
                              color: VaultedColors.accentGold
                                  .withValues(alpha: 0.15),
                              borderRadius: VaultedRadii.brPill,
                            ),
                            child: Text(
                              badge!,
                              style: VaultedTypography.labelSmall.copyWith(
                                color: VaultedColors.accentGold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: VaultedTypography.labelSmall.copyWith(
                          color: VaultedColors.textMuted,
                        )),
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

// ── Behavior toggle tile ──
class _BehaviorToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BehaviorToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
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
          Icon(icon, color: VaultedColors.textSecondary, size: 22),
          const SizedBox(width: VaultedSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: VaultedTypography.bodyLarge),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: VaultedTypography.labelSmall.copyWith(
                      color: VaultedColors.textMuted,
                    )),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
