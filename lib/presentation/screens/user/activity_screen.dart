import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/transaction_providers.dart';

/// Activity screen showing paginated, filterable transaction history.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(transactionListProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    Haptics.lightTap();
    await ref.read(transactionListProvider.notifier).refresh();
  }

  void _showFilterSheet() {
    Haptics.mediumTap();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VaultedColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      builder: (_) => _FilterSheet(
        currentType: ref.read(txFilterTypeProvider),
        currentRange: ref.read(txFilterDateRangeProvider),
        onApply: (type, range) {
          ref.read(txFilterTypeProvider.notifier).state = type;
          ref.read(txFilterDateRangeProvider.notifier).state = range;
          ref.read(transactionListProvider.notifier).refresh();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionListProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: txState.when(
        loading: () => const _ActivitySkeleton(),
        error: (e, _) => _ErrorState(
          message: 'Failed to load activity',
          onRetry: () => ref.read(transactionListProvider.notifier).refresh(),
        ),
        data: (page) {
          if (page.items.isEmpty) return const _EmptyState();

          final grouped = _groupByDate(page.items);

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: VaultedColors.accentGold,
            backgroundColor: VaultedColors.bgCard,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 100),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: grouped.length + (page.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == grouped.length) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: VaultedColors.accentGold,
                        ),
                      ),
                    ),
                  );
                }

                final entry = grouped[index];
                return _DateGroup(
                  label: entry.label,
                  transactions: entry.transactions,
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<_GroupedEntry> _groupByDate(List<TransactionModel> items) {
    final map = <String, List<TransactionModel>>{};

    for (final tx in items) {
      final now = DateTime.now();
      final txDate = tx.createdAt;
      final diff = now.difference(txDate).inDays;

      String label;
      if (diff == 0 &&
          txDate.day == now.day &&
          txDate.month == now.month &&
          txDate.year == now.year) {
        label = 'Today';
      } else if (diff <= 1 &&
          txDate.day == now.subtract(const Duration(days: 1)).day) {
        label = 'Yesterday';
      } else if (diff < 7) {
        label = 'This Week';
      } else {
        label = Formatters.monthYear(txDate);
      }

      map.putIfAbsent(label, () => []).add(tx);
    }

    return map.entries
        .map((e) => _GroupedEntry(label: e.key, transactions: e.value))
        .toList();
  }
}

class _GroupedEntry {
  final String label;
  final List<TransactionModel> transactions;
  const _GroupedEntry({required this.label, required this.transactions});
}

// -- Date group header + items -------------------------------------------

class _DateGroup extends StatelessWidget {
  final String label;
  final List<TransactionModel> transactions;

  const _DateGroup({required this.label, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            VaultedSpacing.xl,
            VaultedSpacing.xxl,
            VaultedSpacing.xl,
            VaultedSpacing.sm,
          ),
          child: Text(
            label.toUpperCase(),
            style: VaultedTypography.labelSmall.copyWith(
              color: VaultedColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...transactions.map((tx) => _TransactionTile(transaction: tx)),
      ],
    );
  }
}

// -- Single transaction tile ---------------------------------------------

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPositive =
        transaction.type == TransactionType.refund || transaction.amount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Haptics.lightTap();
          // Navigate to detail when route is wired
        },
        splashColor: VaultedColors.accentGoldDim,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VaultedSpacing.xl,
            vertical: VaultedSpacing.md,
          ),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconBgColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_iconData, color: _iconBgColor, size: 20),
              ),
              const SizedBox(width: VaultedSpacing.md),

              // Description + retailer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description ??
                          TransactionType.label(transaction.type),
                      style: VaultedTypography.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          transaction.retailer,
                          style: VaultedTypography.bodyMedium,
                        ),
                        const SizedBox(width: VaultedSpacing.sm),
                        _StatusBadge(type: transaction.type),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount + time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? '+' : '-'}\$${transaction.amount.abs().toStringAsFixed(2)}',
                    style: VaultedTypography.monoMedium.copyWith(
                      color: isPositive
                          ? VaultedColors.success
                          : VaultedColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.relativeTime(transaction.createdAt),
                    style: VaultedTypography.labelSmall.copyWith(
                      color: VaultedColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _iconData => switch (transaction.type) {
        TransactionType.purchase => Icons.shopping_bag_outlined,
        TransactionType.refund => Icons.replay_rounded,
        TransactionType.balanceCheck => Icons.account_balance_outlined,
        TransactionType.transfer => Icons.swap_horiz_rounded,
        TransactionType.adjustment => Icons.tune_rounded,
        _ => Icons.receipt_long_outlined,
      };

  Color get _iconBgColor => switch (transaction.type) {
        TransactionType.purchase => VaultedColors.accentGold,
        TransactionType.refund => VaultedColors.success,
        TransactionType.balanceCheck => VaultedColors.info,
        TransactionType.transfer => VaultedColors.warning,
        TransactionType.adjustment => VaultedColors.textSecondary,
        _ => VaultedColors.textMuted,
      };
}

// -- Status badge --------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final String type;
  const _StatusBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: VaultedColors.bgInput,
        borderRadius: VaultedRadii.brBadge,
        border: Border.all(color: VaultedColors.border),
      ),
      child: Text(
        TransactionType.label(type),
        style: VaultedTypography.labelMicro.copyWith(
          color: VaultedColors.textSecondary,
        ),
      ),
    );
  }
}

// -- Filter bottom sheet -------------------------------------------------

class _FilterSheet extends StatefulWidget {
  final String? currentType;
  final DateTimeRange? currentRange;
  final void Function(String? type, DateTimeRange? range) onApply;

  const _FilterSheet({
    this.currentType,
    this.currentRange,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _selectedType;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentType;
    _selectedRange = widget.currentRange;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: VaultedSpacing.bottomSheet,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Activity', style: VaultedTypography.headlineMedium),
          VaultedSpacing.gapXl,

          // Type filter chips
          Text(
            'TRANSACTION TYPE',
            style: VaultedTypography.labelSmall.copyWith(
              letterSpacing: 1.2,
              color: VaultedColors.textMuted,
            ),
          ),
          VaultedSpacing.gapSm,
          Wrap(
            spacing: VaultedSpacing.sm,
            runSpacing: VaultedSpacing.sm,
            children: [
              _buildChip('All', null),
              ...TransactionType.all.map(
                (t) => _buildChip(TransactionType.label(t), t),
              ),
            ],
          ),
          VaultedSpacing.gapXl,

          // Date range
          Text(
            'DATE RANGE',
            style: VaultedTypography.labelSmall.copyWith(
              letterSpacing: 1.2,
              color: VaultedColors.textMuted,
            ),
          ),
          VaultedSpacing.gapSm,
          Wrap(
            spacing: VaultedSpacing.sm,
            runSpacing: VaultedSpacing.sm,
            children: [
              _buildDateChip('All Time', null),
              _buildDateChip('Today', DateTimeRange(
                start: DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
                end: DateTime.now(),
              )),
              _buildDateChip('This Week', DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 7)),
                end: DateTime.now(),
              )),
              _buildDateChip('This Month', DateTimeRange(
                start: DateTime(DateTime.now().year, DateTime.now().month),
                end: DateTime.now(),
              )),
            ],
          ),
          VaultedSpacing.gapXxl,

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Haptics.mediumTap();
                widget.onApply(_selectedType, _selectedRange);
              },
              child: const Text('Apply Filters'),
            ),
          ),
          VaultedSpacing.gapMd,

          // Clear button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Haptics.lightTap();
                widget.onApply(null, null);
              },
              child: const Text('Clear All'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        Haptics.selection();
        setState(() => _selectedType = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? VaultedColors.accentGoldDim : VaultedColors.bgInput,
          borderRadius: VaultedRadii.brPill,
          border: Border.all(
            color: isSelected
                ? VaultedColors.accentGold
                : VaultedColors.border,
          ),
        ),
        child: Text(
          label,
          style: VaultedTypography.bodyMedium.copyWith(
            color: isSelected
                ? VaultedColors.accentGold
                : VaultedColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(String label, DateTimeRange? value) {
    final isSelected = _selectedRange?.start == value?.start &&
        _selectedRange?.end == value?.end;
    return GestureDetector(
      onTap: () {
        Haptics.selection();
        setState(() => _selectedRange = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? VaultedColors.accentGoldDim : VaultedColors.bgInput,
          borderRadius: VaultedRadii.brPill,
          border: Border.all(
            color: isSelected
                ? VaultedColors.accentGold
                : VaultedColors.border,
          ),
        ),
        child: Text(
          label,
          style: VaultedTypography.bodyMedium.copyWith(
            color: isSelected
                ? VaultedColors.accentGold
                : VaultedColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// -- Empty state ---------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: VaultedColors.accentGoldDim,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: VaultedColors.accentGold,
              size: 32,
            ),
          ),
          VaultedSpacing.gapXl,
          Text(
            'No activity yet',
            style: VaultedTypography.headlineMedium,
          ),
          VaultedSpacing.gapSm,
          Text(
            'Your transactions will appear here',
            style: VaultedTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// -- Error state ---------------------------------------------------------

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: VaultedColors.danger,
            size: 40,
          ),
          VaultedSpacing.gapLg,
          Text(message, style: VaultedTypography.bodyLarge),
          VaultedSpacing.gapLg,
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// -- Skeleton loading ----------------------------------------------------

class _ActivitySkeleton extends StatelessWidget {
  const _ActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: VaultedColors.shimmerBase,
      highlightColor: VaultedColors.shimmerHighlight,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: VaultedSpacing.xl,
          vertical: VaultedSpacing.lg,
        ),
        itemCount: 8,
        itemBuilder: (_, _) => Padding(
          padding: const EdgeInsets.only(bottom: VaultedSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: VaultedColors.bgCard,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: VaultedSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: VaultedColors.bgCard,
                        borderRadius: VaultedRadii.brBadge,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 10,
                      decoration: BoxDecoration(
                        color: VaultedColors.bgCard,
                        borderRadius: VaultedRadii.brBadge,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: VaultedColors.bgCard,
                      borderRadius: VaultedRadii.brBadge,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      color: VaultedColors.bgCard,
                      borderRadius: VaultedRadii.brBadge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
