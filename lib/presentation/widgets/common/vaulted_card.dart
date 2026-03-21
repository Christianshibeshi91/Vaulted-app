import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';

/// Reusable card container following the Vaulted design language.
///
/// Provides [VaultedColors.bgCard] background, a subtle 8 % gold border,
/// and an optional [onTap] with a ripple tinted to [VaultedColors.bgCardPressed].
class VaultedCard extends StatelessWidget {
  const VaultedCard({
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? VaultedRadii.brCard;
    final content = Padding(
      padding: padding ?? VaultedSpacing.cardInner,
      child: child,
    );

    return Material(
      color: VaultedColors.bgCard,
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: VaultedColors.border),
        ),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: radius,
                splashColor: VaultedColors.accentGoldDim,
                highlightColor: VaultedColors.bgCardPressed,
                child: content,
              )
            : content,
      ),
    );
  }
}
