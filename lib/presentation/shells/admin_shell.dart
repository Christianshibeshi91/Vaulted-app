import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Bottom-tab shell for admin screens with a drawer for secondary routes.
///
/// Uses [StatefulNavigationShell] from go_router to preserve each
/// branch's navigation stack independently across 5 tabs.
class AdminShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShell({super.key, required this.navigationShell});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Tab definitions ──────────────────────────────────────────────
  static const _tabs = <_TabDef>[
    _TabDef(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: 'HOME'),
    _TabDef(icon: Icons.people_outline, activeIcon: Icons.people, label: 'USERS'),
    _TabDef(icon: Icons.credit_card_outlined, activeIcon: Icons.credit_card, label: 'CARDS'),
    _TabDef(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'ACTIVITY'),
    _TabDef(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'SETTINGS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: VaultedColors.bgPrimary,
      drawer: const _AdminDrawer(),
      body: Column(
        children: [
          _AdminHeader(onMenuTap: () => _scaffoldKey.currentState?.openDrawer()),
          Expanded(child: widget.navigationShell),
        ],
      ),
      bottomNavigationBar: _AdminBottomBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTabTap,
      ),
    );
  }

  void _onTabTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

// ── Tab definition model ─────────────────────────────────────────────
class _TabDef {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabDef({required this.icon, required this.activeIcon, required this.label});
}

// =====================================================================
//  HEADER
// =====================================================================

class _AdminHeader extends StatelessWidget {
  final VoidCallback onMenuTap;

  const _AdminHeader({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Admin';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';
    final photoUrl = user?.photoURL;

    return Container(
      color: VaultedColors.bgSecondary,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: VaultedColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Hamburger menu
              GestureDetector(
                onTap: onMenuTap,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.menu,
                    color: VaultedColors.accentGold,
                    size: 22,
                  ),
                ),
              ),

              // Centered title
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VAULTED',
                      style: VaultedTypography.gold(
                        VaultedTypography.labelSmall,
                      ).copyWith(letterSpacing: 3.0),
                    ),
                    Text(
                      'ADMIN CONSOLE',
                      style: VaultedTypography.muted(
                        VaultedTypography.labelMicro,
                      ).copyWith(letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),

              // User avatar
              GestureDetector(
                onTap: () => context.go(RoutePaths.adminSettings),
                behavior: HitTestBehavior.opaque,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: VaultedColors.accentGoldDim,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Text(
                          initial,
                          style: VaultedTypography.gold(
                            VaultedTypography.labelSmall,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
//  BOTTOM BAR
// =====================================================================

class _AdminBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AdminBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VaultedColors.bgSecondary,
        border: const Border(
          top: BorderSide(color: VaultedColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_AdminShellState._tabs.length, (i) {
              final tab = _AdminShellState._tabs[i];
              return _AdminNavItem(
                icon: tab.icon,
                activeIcon: tab.activeIcon,
                label: tab.label,
                isActive: currentIndex == i,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Individual nav item ──────────────────────────────────────────────

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? VaultedColors.accentGold : VaultedColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gold accent indicator line above icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: isActive ? 16 : 0,
              height: 2.5,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: VaultedColors.accentGold,
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: VaultedColors.accentGold
                              .withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),

            // Icon with active background
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? VaultedColors.accentGold.withValues(alpha: 0.12)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey(isActive),
                  color: color,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(height: 2),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: VaultedTypography.labelMicro.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.8,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
//  DRAWER  (secondary routes: Revenue, Analytics, Feature Flags, etc.)
// =====================================================================

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer();

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

            // ── Additional admin routes ─────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.analytics_outlined,
                    label: 'Revenue',
                    path: RoutePaths.adminRevenue,
                    currentPath: currentPath,
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Analytics',
                    path: RoutePaths.adminAnalytics,
                    currentPath: currentPath,
                  ),
                  _DrawerItem(
                    icon: Icons.flag_outlined,
                    label: 'Feature Flags',
                    path: RoutePaths.adminFeatureFlags,
                    currentPath: currentPath,
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    label: 'Alerts',
                    path: RoutePaths.adminAlerts,
                    currentPath: currentPath,
                  ),
                  _DrawerItem(
                    icon: Icons.history,
                    label: 'Audit Log',
                    path: RoutePaths.adminAuditLog,
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

            const _AdminFooter(),
          ],
        ),
      ),
    );
  }
}

// ── Drawer nav item ──────────────────────────────────────────────────

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
          color: _isActive
              ? VaultedColors.accentGold
              : VaultedColors.textSecondary,
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

// ── Drawer footer ────────────────────────────────────────────────────

class _AdminFooter extends StatelessWidget {
  const _AdminFooter();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Admin';
    final email = user?.email ?? '';
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: VaultedColors.accentGoldDim,
            child: Text(
              initial,
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
                Text(displayName, style: VaultedTypography.bodyMedium),
                Text(
                  email,
                  style: VaultedTypography.muted(
                    VaultedTypography.labelMicro,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
