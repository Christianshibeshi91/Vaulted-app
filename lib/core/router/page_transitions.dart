import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Page transition presets for the Vaulted router.
///
/// Three flavours:
/// - [authTransition] -- fade + slide-up for auth screens (300ms)
/// - [tabTransition]  -- cross-fade for bottom-nav tab switches (200ms)
/// - [detailTransition] -- slide left/right for detail push/pop (250ms)
abstract final class VaultedPageTransitions {
  // ── Auth: fade + slide up ───────────────────────────────────────

  /// Fade-in with a gentle upward slide. Suitable for login, register,
  /// verify-email, and other authentication screens.
  static CustomTransitionPage<T> authTransition<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // ── Tab: cross-fade ─────────────────────────────────────────────

  /// Quick cross-fade for switching between bottom-navigation tabs.
  static CustomTransitionPage<T> tabTransition<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }

  // ── Detail: horizontal slide ────────────────────────────────────

  /// Slide-in from the right (push) / slide-out to the right (pop).
  /// Used for card detail, transaction detail, and similar drill-down
  /// screens.
  static CustomTransitionPage<T> detailTransition<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        // Outgoing page slides slightly left and fades.
        final secondaryCurved = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.92)
                .animate(secondaryCurved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.15, 0),
              ).animate(secondaryCurved),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
