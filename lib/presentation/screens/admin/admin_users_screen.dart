import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/user_model.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/admin/admin_user_list_item.dart';

/// Filter state for user list.
final _userFilterProvider = StateProvider<String>((_) => 'all');
final _userSearchProvider = StateProvider<String>((_) => '');

/// Admin user management screen with search and filter.
class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final filter = ref.watch(_userFilterProvider);
    final search = ref.watch(_userSearchProvider).toLowerCase();

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              onChanged: (val) =>
                  ref.read(_userSearchProvider.notifier).state = val,
              style: VaultedTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => ref
                            .read(_userSearchProvider.notifier)
                            .state = '',
                      )
                    : null,
              ),
            ),
          ),

          // ── Filter pills ────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterPill(
                  label: 'All',
                  isActive: filter == 'all',
                  onTap: () => ref
                      .read(_userFilterProvider.notifier)
                      .state = 'all',
                ),
                _FilterPill(
                  label: 'Active',
                  isActive: filter == 'active',
                  onTap: () => ref
                      .read(_userFilterProvider.notifier)
                      .state = 'active',
                ),
                _FilterPill(
                  label: 'Suspended',
                  isActive: filter == 'suspended',
                  onTap: () => ref
                      .read(_userFilterProvider.notifier)
                      .state = 'suspended',
                ),
                _FilterPill(
                  label: 'Premium',
                  isActive: filter == 'premium',
                  onTap: () => ref
                      .read(_userFilterProvider.notifier)
                      .state = 'premium',
                ),
              ],
            ),
          ),

          VaultedSpacing.gapSm,

          // ── User list ───────────────────────────────────────
          Expanded(
            child: usersAsync.when(
              data: (users) {
                var filtered = _applyFilters(users, filter, search);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_search,
                          color: VaultedColors.textMuted,
                          size: 40,
                        ),
                        VaultedSpacing.gapMd,
                        Text(
                          'No users found',
                          style: VaultedTypography.muted(
                              VaultedTypography.bodyLarge),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => VaultedSpacing.gapSm,
                  itemBuilder: (_, index) {
                    final user = filtered[index];
                    return AdminUserListItem(
                      user: user,
                      onTap: () => context.go('/admin/users/${user.uid}'),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: VaultedColors.accentGold,
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load users',
                  style: VaultedTypography.muted(VaultedTypography.bodyLarge),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<UserModel> _applyFilters(
    List<UserModel> users,
    String filter,
    String search,
  ) {
    var result = users;

    // Status filter
    if (filter == 'active') {
      result = result.where((u) => !u.isSuspended).toList();
    } else if (filter == 'suspended') {
      result = result.where((u) => u.isSuspended).toList();
    } else if (filter == 'premium') {
      result = result.where((u) => u.plan == 'premium').toList();
    }

    // Search filter
    if (search.isNotEmpty) {
      result = result.where((u) {
        final name = (u.displayName ?? '').toLowerCase();
        final email = u.email.toLowerCase();
        return name.contains(search) || email.contains(search);
      }).toList();
    }

    return result;
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: VaultedSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: VaultedRadii.brPill,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? VaultedColors.accentGoldDim
                  : VaultedColors.bgInput,
              borderRadius: VaultedRadii.brPill,
              border: Border.all(
                color: isActive
                    ? VaultedColors.accentGold
                    : VaultedColors.border,
              ),
            ),
            child: Text(
              label,
              style: VaultedTypography.bodyMedium.copyWith(
                color: isActive
                    ? VaultedColors.accentGold
                    : VaultedColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
