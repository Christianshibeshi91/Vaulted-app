import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Themed [RefreshIndicator] that uses gold accent colours and the
/// dark card background, matching the Vaulted design system.
///
/// Wrap any scrollable child to get a consistent pull-to-refresh:
///
/// ```dart
/// VaultedRefreshIndicator(
///   onRefresh: () async {
///     ref.invalidate(cardsProvider);
///   },
///   child: ListView(...),
/// )
/// ```
class VaultedRefreshIndicator extends StatelessWidget {
  const VaultedRefreshIndicator({
    required this.onRefresh,
    required this.child,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    super.key,
  });

  /// Called when the user has dragged far enough to trigger a refresh.
  final RefreshCallback onRefresh;

  /// The scrollable child (must contain a [Scrollable]).
  final Widget child;

  /// Distance from the top to the refresh indicator (default 40).
  final double displacement;

  /// Additional top offset for the indicator, useful when placed
  /// under a pinned app bar.
  final double edgeOffset;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: VaultedColors.accentGold,
      backgroundColor: VaultedColors.bgCard,
      displacement: displacement,
      edgeOffset: edgeOffset,
      strokeWidth: 2.5,
      child: child,
    );
  }
}
