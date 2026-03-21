import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Circular user avatar with a gold border ring.
///
/// Falls back to the user's initials on a [VaultedColors.bgCard] background
/// when [imageUrl] is null or fails to load. Set [isEditable] to overlay a
/// camera icon for profile-edit screens.
class VaultedAvatar extends StatelessWidget {
  const VaultedAvatar({
    this.imageUrl,
    this.name,
    this.size = 48,
    this.onTap,
    this.isEditable = false,
    super.key,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final VoidCallback? onTap;
  final bool isEditable;

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final borderWidth = size > 64 ? 2.5 : 2.0;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: VaultedColors.accentGold,
          width: borderWidth,
        ),
      ),
      child: ClipOval(child: _buildInner()),
    );

    if (isEditable) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: const BoxDecoration(
                color: VaultedColors.accentGold,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: size * 0.18,
                color: VaultedColors.bgPrimary,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInner() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        placeholder: (_, _) => _initialsWidget(),
        errorWidget: (_, _, _) => _initialsWidget(),
      );
    }
    return _initialsWidget();
  }

  Widget _initialsWidget() {
    final fontSize = size * 0.36;
    return Container(
      color: VaultedColors.bgCard,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: VaultedTypography.bodyLarge.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: VaultedColors.accentGold,
          height: 1.0,
        ),
      ),
    );
  }
}
