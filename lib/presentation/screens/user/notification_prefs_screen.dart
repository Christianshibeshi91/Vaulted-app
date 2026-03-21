import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/auth_providers.dart';

/// Notification preference toggles.
class NotificationPrefsScreen extends ConsumerStatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  ConsumerState<NotificationPrefsScreen> createState() =>
      _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState
    extends ConsumerState<NotificationPrefsScreen> {
  // Local state mirrors Firestore prefs; saved on toggle.
  late bool _balanceAlerts;
  late bool _expirationReminders;
  late bool _securityAlerts;
  late bool _marketing;
  bool _initialized = false;

  void _initFromUser(Map<String, bool>? prefs) {
    if (_initialized) return;
    _balanceAlerts = prefs?['balanceAlerts'] ?? true;
    _expirationReminders = prefs?['expirationReminders'] ?? true;
    _securityAlerts = prefs?['securityAlerts'] ?? true;
    _marketing = prefs?['marketing'] ?? false;
    _initialized = true;
  }

  void _onToggle(String key, bool value) {
    Haptics.toggle();
    setState(() {
      switch (key) {
        case 'balanceAlerts':
          _balanceAlerts = value;
        case 'expirationReminders':
          _expirationReminders = value;
        case 'securityAlerts':
          _securityAlerts = value;
        case 'marketing':
          _marketing = value;
      }
    });
    // In production, persist to Firestore: users/{uid}.notificationPreferences
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: VaultedColors.accentGold),
        ),
        error: (_, _) => const Center(child: Text('Failed to load')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          _initFromUser(user.notificationPreferences);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: VaultedSpacing.lg),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                  vertical: VaultedSpacing.sm,
                ),
                child: Text(
                  'Choose which notifications you receive.',
                  style: VaultedTypography.bodyMedium,
                ),
              ),
              VaultedSpacing.gapLg,
              _PrefTile(
                title: 'Balance Alerts',
                description:
                    'Get notified when a card balance changes or reaches zero.',
                value: _balanceAlerts,
                onChanged: (v) => _onToggle('balanceAlerts', v),
              ),
              _PrefTile(
                title: 'Expiration Reminders',
                description:
                    'Receive reminders before a gift card expires.',
                value: _expirationReminders,
                onChanged: (v) => _onToggle('expirationReminders', v),
              ),
              _PrefTile(
                title: 'Security Alerts',
                description:
                    'Important alerts about account security and login activity.',
                value: _securityAlerts,
                onChanged: (v) => _onToggle('securityAlerts', v),
              ),
              _PrefTile(
                title: 'Marketing',
                description:
                    'Promotions, tips, and product updates from Vaulted.',
                value: _marketing,
                onChanged: (v) => _onToggle('marketing', v),
              ),
            ],
          );
        },
      ),
    );
  }
}

// -- Preference toggle tile ----------------------------------------------

class _PrefTile extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrefTile({
    required this.title,
    required this.description,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: VaultedTypography.bodyLarge),
                const SizedBox(height: 4),
                Text(description, style: VaultedTypography.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: VaultedSpacing.md),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
