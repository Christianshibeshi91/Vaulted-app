import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';

/// Skeleton loading placeholders with a shimmer animation.
///
/// Uses [VaultedColors.shimmerBase] as the base colour and
/// [VaultedColors.shimmerHighlight] for the sweeping highlight.
class VaultedSkeleton extends StatelessWidget {
  const VaultedSkeleton._({
    required this.width,
    required this.height,
    required this.borderRadius,
    super.key,
  });

  /// Rectangular skeleton placeholder.
  factory VaultedSkeleton.box({
    double? width,
    double height = 48,
    double borderRadius = VaultedRadii.card,
    Key? key,
  }) =>
      VaultedSkeleton._(
        width: width,
        height: height,
        borderRadius: borderRadius,
        key: key,
      );

  /// Circular skeleton placeholder (e.g. avatar).
  factory VaultedSkeleton.circle({
    double size = 48,
    Key? key,
  }) =>
      VaultedSkeleton._(
        width: size,
        height: size,
        borderRadius: size / 2,
        key: key,
      );

  /// Multiple text-line skeleton placeholders.
  ///
  /// Returns a [Column] of shimmer bars that approximate lines of text.
  static Widget text({
    double? width,
    int lines = 3,
    Key? key,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines, (i) {
        final isLast = i == lines - 1;
        return Padding(
          padding: EdgeInsets.only(
            bottom: isLast ? 0 : VaultedSpacing.sm,
          ),
          child: VaultedSkeleton._(
            width: isLast ? (width ?? double.infinity) * 0.6 : width,
            height: 14,
            borderRadius: 4,
          ),
        );
      }),
    );
  }

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: VaultedColors.shimmerBase,
      highlightColor: VaultedColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: VaultedColors.shimmerBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
