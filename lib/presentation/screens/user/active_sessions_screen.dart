import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';

/// Displays active login sessions with revoke capabilities.
class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  // Placeholder session data. In production, fetched from Firestore or an API.
  late final List<_SessionData> _sessions = [
    _SessionData(
      id: '1',
      device: 'iPhone 15 Pro',
      platform: 'iOS 18.2',
      location: 'London, UK',
      lastActive: DateTime.now(),
      isCurrent: true,
    ),
    _SessionData(
      id: '2',
      device: 'Chrome on MacBook',
      platform: 'macOS Sequoia',
      location: 'London, UK',
      lastActive: DateTime.now().subtract(const Duration(hours: 3)),
      isCurrent: false,
    ),
    _SessionData(
      id: '3',
      device: 'iPad Air',
      platform: 'iPadOS 18.2',
      location: 'Manchester, UK',
      lastActive: DateTime.now().subtract(const Duration(days: 2)),
      isCurrent: false,
    ),
  ];

  void _revokeSession(String sessionId) {
    Haptics.heavyTap();
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
              size: 36,
            ),
            VaultedSpacing.gapLg,
            Text('Revoke Session?', style: VaultedTypography.headlineMedium),
            VaultedSpacing.gapSm,
            Text(
              'This device will be signed out immediately.',
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
                onPressed: () {
                  Haptics.heavyTap();
                  Navigator.pop(ctx);
                  setState(() {
                    _sessions.removeWhere((s) => s.id == sessionId);
                  });
                },
                child: const Text('Revoke'),
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

  void _revokeAllOther() {
    Haptics.heavyTap();
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
              Icons.devices_other_rounded,
              color: VaultedColors.danger,
              size: 36,
            ),
            VaultedSpacing.gapLg,
            Text(
              'Revoke All Other Sessions?',
              style: VaultedTypography.headlineMedium,
            ),
            VaultedSpacing.gapSm,
            Text(
              'All devices except this one will be signed out.',
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
                onPressed: () {
                  Haptics.heavyTap();
                  Navigator.pop(ctx);
                  setState(() {
                    _sessions.removeWhere((s) => !s.isCurrent);
                  });
                },
                child: const Text('Revoke All'),
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

  @override
  Widget build(BuildContext context) {
    final otherSessions = _sessions.where((s) => !s.isCurrent).toList();

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(title: const Text('Active Sessions')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Revoke all button
          if (otherSessions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VaultedSpacing.xl,
                VaultedSpacing.lg,
                VaultedSpacing.xl,
                VaultedSpacing.sm,
              ),
              child: OutlinedButton.icon(
                onPressed: _revokeAllOther,
                icon: const Icon(Icons.block_rounded, size: 18),
                style: OutlinedButton.styleFrom(
                  foregroundColor: VaultedColors.danger,
                  side: BorderSide(
                    color: VaultedColors.danger.withValues(alpha: 0.3),
                  ),
                ),
                label: const Text('Revoke All Other Sessions'),
              ),
            ),

          VaultedSpacing.gapMd,

          // Session list
          ..._sessions.map((session) => _SessionTile(
                session: session,
                onRevoke: session.isCurrent
                    ? null
                    : () => _revokeSession(session.id),
              )),
        ],
      ),
    );
  }
}

// -- Session tile --------------------------------------------------------

class _SessionTile extends StatelessWidget {
  final _SessionData session;
  final VoidCallback? onRevoke;

  const _SessionTile({required this.session, this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VaultedSpacing.xl,
        vertical: VaultedSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(VaultedSpacing.lg),
        decoration: BoxDecoration(
          color: VaultedColors.bgCard,
          borderRadius: VaultedRadii.brCard,
          border: Border.all(
            color: session.isCurrent
                ? VaultedColors.accentGold.withValues(alpha: 0.3)
                : VaultedColors.border,
          ),
        ),
        child: Row(
          children: [
            // Device icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: session.isCurrent
                    ? VaultedColors.accentGoldDim
                    : VaultedColors.bgInput,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _deviceIcon,
                color: session.isCurrent
                    ? VaultedColors.accentGold
                    : VaultedColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: VaultedSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          session.device,
                          style: VaultedTypography.bodyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (session.isCurrent) ...[
                        const SizedBox(width: VaultedSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: VaultedColors.success.withValues(alpha: 0.12),
                            borderRadius: VaultedRadii.brBadge,
                          ),
                          child: Text(
                            'THIS DEVICE',
                            style: VaultedTypography.labelMicro.copyWith(
                              color: VaultedColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.platform}  |  ${session.location}',
                    style: VaultedTypography.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.isCurrent
                        ? 'Active now'
                        : Formatters.relativeTime(session.lastActive),
                    style: VaultedTypography.labelSmall.copyWith(
                      color: session.isCurrent
                          ? VaultedColors.success
                          : VaultedColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Revoke button
            if (onRevoke != null)
              IconButton(
                onPressed: onRevoke,
                icon: const Icon(Icons.close_rounded),
                color: VaultedColors.danger,
                tooltip: 'Revoke',
                iconSize: 20,
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData get _deviceIcon {
    final device = session.device.toLowerCase();
    if (device.contains('iphone') || device.contains('android')) {
      return Icons.smartphone_rounded;
    }
    if (device.contains('ipad') || device.contains('tablet')) {
      return Icons.tablet_rounded;
    }
    return Icons.laptop_rounded;
  }
}

// -- Session data model --------------------------------------------------

class _SessionData {
  final String id;
  final String device;
  final String platform;
  final String location;
  final DateTime lastActive;
  final bool isCurrent;

  const _SessionData({
    required this.id,
    required this.device,
    required this.platform,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });
}
