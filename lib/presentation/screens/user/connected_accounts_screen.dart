import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Manage connected OAuth accounts (Google, Apple).
class ConnectedAccountsScreen extends StatefulWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  State<ConnectedAccountsScreen> createState() =>
      _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState extends State<ConnectedAccountsScreen> {
  // Placeholder state -- in production, read from Firebase auth providers.
  bool _googleConnected = false;
  bool _appleConnected = false;

  void _toggleGoogle() {
    Haptics.mediumTap();
    if (_googleConnected) {
      _showDisconnectSheet('Google', () {
        setState(() => _googleConnected = false);
      });
    } else {
      // Trigger Google sign-in link flow
      setState(() => _googleConnected = true);
      Haptics.success();
    }
  }

  void _toggleApple() {
    Haptics.mediumTap();
    if (_appleConnected) {
      _showDisconnectSheet('Apple', () {
        setState(() => _appleConnected = false);
      });
    } else {
      // Trigger Apple sign-in link flow
      setState(() => _appleConnected = true);
      Haptics.success();
    }
  }

  void _showDisconnectSheet(String provider, VoidCallback onConfirm) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VaultedColors.bgSecondary,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: VaultedSpacing.bottomSheet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.link_off_rounded,
              color: VaultedColors.warning,
              size: 36,
            ),
            VaultedSpacing.gapLg,
            Text(
              'Disconnect $provider?',
              style: VaultedTypography.headlineMedium,
            ),
            VaultedSpacing.gapSm,
            Text(
              'You will no longer be able to sign in with $provider.',
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
                  onConfirm();
                },
                child: const Text('Disconnect'),
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
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(title: const Text('Connected Accounts')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: VaultedSpacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: VaultedSpacing.xl,
              vertical: VaultedSpacing.sm,
            ),
            child: Text(
              'Link external accounts for faster sign-in.',
              style: VaultedTypography.bodyMedium,
            ),
          ),
          VaultedSpacing.gapLg,

          // Google
          _AccountTile(
            icon: Icons.g_mobiledata_rounded,
            iconColor: VaultedColors.danger,
            title: 'Google',
            isConnected: _googleConnected,
            onTap: _toggleGoogle,
          ),

          // Apple
          _AccountTile(
            icon: Icons.apple_rounded,
            iconColor: VaultedColors.textPrimary,
            title: 'Apple',
            isConnected: _appleConnected,
            onTap: _toggleApple,
          ),
        ],
      ),
    );
  }
}

// -- Account tile --------------------------------------------------------

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isConnected;
  final VoidCallback onTap;

  const _AccountTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isConnected,
    required this.onTap,
  });

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
          border: Border.all(color: VaultedColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: VaultedColors.bgInput,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: VaultedSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: VaultedTypography.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    isConnected ? 'Connected' : 'Not connected',
                    style: VaultedTypography.bodyMedium.copyWith(
                      color: isConnected
                          ? VaultedColors.success
                          : VaultedColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isConnected
                      ? VaultedColors.danger
                      : VaultedColors.accentGold,
                  side: BorderSide(
                    color: isConnected
                        ? VaultedColors.danger.withValues(alpha: 0.3)
                        : VaultedColors.borderStrong,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(0, 36),
                ),
                child: Text(isConnected ? 'Disconnect' : 'Connect'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
