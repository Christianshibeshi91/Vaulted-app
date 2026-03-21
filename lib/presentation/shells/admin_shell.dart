import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Drawer-based shell for admin screens.
///
/// Wraps every route under `/admin/*` with a consistent app bar
/// and navigation drawer.
class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: VaultedColors.bgSecondary,
        elevation: 0,
        title: Text(
          'ADMIN CONSOLE',
          style: VaultedTypography.gold(VaultedTypography.labelSmall).copyWith(
            letterSpacing: 2.0,
          ),
        ),
        iconTheme: const IconThemeData(color: VaultedColors.accentGold),
      ),
      drawer: _AdminDrawer(),
      body: child,
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: VaultedColors.bgSecondary,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: VaultedColors.accentGoldDim,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: VaultedColors.accentGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VAULTED',
                        style: VaultedTypography.gold(
                          VaultedTypography.labelSmall,
                        ).copyWith(letterSpacing: 3.0),
                      ),
                      Text(
                        'Admin Console',
                        style: VaultedTypography.muted(
                          VaultedTypography.labelMicro,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: VaultedColors.border, height: 1),

            // ── Nav items ───────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    path: RoutePaths.admin,
                    currentPath: currentPath,
                  ),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    label: 'Users',
                    path: RoutePaths.adminUsers,
                    currentPath: currentPath,
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transactions',
                    path: RoutePaths.adminTransactions,
                    currentPath: currentPath,
                  ),
                  _DrawerItem(
                    icon: Icons.credit_card_outlined,
                    label: 'Cards',
                    path: RoutePaths.adminCards,
                    currentPath: currentPath,
                  ),
                  _DrawerItem(
                    icon: Icons.analytics_outlined,
                    label: 'Analytics',
                    path: RoutePaths.adminAnalytics,
                    currentPath: currentPath,
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    path: RoutePaths.adminSettings,
                    currentPath: currentPath,
                  ),
                ],
              ),
            ),

            // ── Footer ─────────────────────────────────────
            const Divider(color: VaultedColors.border, height: 1),
            _DrawerItem(
              icon: Icons.swap_horiz,
              label: 'Switch to User View',
              path: RoutePaths.home,
              currentPath: currentPath,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: VaultedColors.accentGoldDim,
                    child: Text(
                      'A',
                      style: VaultedTypography.gold(
                        VaultedTypography.labelSmall,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin', style: VaultedTypography.bodyMedium),
                        Text(
                          'admin@vaulted.app',
                          style: VaultedTypography.muted(
                            VaultedTypography.labelMicro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final String currentPath;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.currentPath,
  });

  bool get _isActive => currentPath == path;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: _isActive ? VaultedColors.accentGold : VaultedColors.textMuted,
        size: 20,
      ),
      title: Text(
        label,
        style: (_isActive
                ? VaultedTypography.bodyLarge
                : VaultedTypography.bodyMedium)
            .copyWith(
          color:
              _isActive ? VaultedColors.accentGold : VaultedColors.textSecondary,
        ),
      ),
      tileColor: _isActive ? VaultedColors.accentGoldDim : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: () {
        Navigator.of(context).pop(); // close drawer
        context.go(path);
      },
    );
  }
}
