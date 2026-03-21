import 'package:flutter/material.dart';

/// Border-radius tokens for the Vaulted design system.
abstract final class VaultedRadii {
  static const double card = 16;
  static const double button = 10;
  static const double input = 10;
  static const double badge = 6;
  static const double bottomSheet = 24;
  static const double pill = 999;

  // ── BorderRadius shortcuts ───────────────────────────────────

  static final brCard = BorderRadius.circular(card);
  static final brButton = BorderRadius.circular(button);
  static final brInput = BorderRadius.circular(input);
  static final brBadge = BorderRadius.circular(badge);
  static final brBottomSheet = const BorderRadius.vertical(
    top: Radius.circular(bottomSheet),
  );
  static final brPill = BorderRadius.circular(pill);

  // ── ShapeBorder shortcuts ────────────────────────────────────

  static final shapeCard = RoundedRectangleBorder(borderRadius: brCard);
  static final shapeButton = RoundedRectangleBorder(borderRadius: brButton);
  static final shapeInput = RoundedRectangleBorder(borderRadius: brInput);
  static final shapePill = RoundedRectangleBorder(borderRadius: brPill);
}
