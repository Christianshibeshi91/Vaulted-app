import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import 'data_export_screen.dart';

/// Account deletion screen with confirmation flow.
///
/// Requires the user to type "DELETE" before the action is enabled.
/// Calls the `deleteUserCascade` Cloud Function to remove all
/// subcollections, then deletes the Firebase Auth account.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmController = TextEditingController();
  bool _isDeleting = false;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _confirmController.removeListener(_onTextChanged);
    _confirmController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final confirmed = _confirmController.text.trim() == 'DELETE';
    if (confirmed != _isConfirmed) {
      setState(() => _isConfirmed = confirmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: VaultedColors.bgPrimary,
        title: Text('Delete Account', style: VaultedTypography.headlineLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(VaultedSpacing.xl),
        children: [
          // ── Warning Section ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(VaultedSpacing.xl),
            decoration: BoxDecoration(
              color: VaultedColors.danger.withValues(alpha: 0.05),
              borderRadius: VaultedRadii.brCard,
              border: Border.all(
                color: VaultedColors.danger.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: VaultedColors.danger.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: VaultedColors.danger,
                    size: 32,
                  ),
                ),
                VaultedSpacing.gapLg,
                Text(
                  'This action is permanent',
                  style: VaultedTypography.headlineMedium.copyWith(
                    color: VaultedColors.danger,
                  ),
                  textAlign: TextAlign.center,
                ),
                VaultedSpacing.gapSm,
                Text(
                  'Deleting your account will permanently remove all of your '
                  'data from our servers. This action cannot be undone.',
                  style: VaultedTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(
                begin: 0.05,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOut,
              ),

          VaultedSpacing.gapXxl,

          // ── What gets deleted ──────────────────────────────────
          Container(
            padding: VaultedSpacing.cardInner,
            decoration: BoxDecoration(
              color: VaultedColors.bgCard,
              borderRadius: VaultedRadii.brCard,
              border: Border.all(color: VaultedColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What will be deleted',
                  style: VaultedTypography.headlineMedium,
                ),
                VaultedSpacing.gapLg,
                _DeletionItem(
                  icon: Icons.credit_card_outlined,
                  label: 'All gift cards and their encrypted data',
                ),
                VaultedSpacing.gapMd,
                _DeletionItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Complete transaction history',
                ),
                VaultedSpacing.gapMd,
                _DeletionItem(
                  icon: Icons.person_outline,
                  label: 'Your profile and personal information',
                ),
                VaultedSpacing.gapMd,
                _DeletionItem(
                  icon: Icons.notifications_none_outlined,
                  label: 'Notification preferences and settings',
                ),
                VaultedSpacing.gapMd,
                _DeletionItem(
                  icon: Icons.devices_outlined,
                  label: 'All active sessions and device data',
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(
                duration: 400.ms,
                delay: 100.ms,
                curve: Curves.easeOut,
              ),

          VaultedSpacing.gapXxl,

          // ── Export Data First ──────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Haptics.lightTap();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DataExportScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Export Data First'),
            ),
          )
              .animate()
              .fadeIn(
                duration: 400.ms,
                delay: 150.ms,
                curve: Curves.easeOut,
              ),

          VaultedSpacing.gapXxl,

          // ── Confirmation Input ─────────────────────────────────
          Container(
            padding: VaultedSpacing.cardInner,
            decoration: BoxDecoration(
              color: VaultedColors.bgCard,
              borderRadius: VaultedRadii.brCard,
              border: Border.all(color: VaultedColors.border),
            ),
            child: Column(
              children: [
                Text(
                  'Type DELETE to confirm',
                  style: VaultedTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                VaultedSpacing.gapMd,
                TextField(
                  controller: _confirmController,
                  textAlign: TextAlign.center,
                  enabled: !_isDeleting,
                  style: VaultedTypography.monoMedium.copyWith(
                    color: _isConfirmed
                        ? VaultedColors.danger
                        : VaultedColors.textPrimary,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'DELETE',
                    hintStyle: VaultedTypography.monoMedium.copyWith(
                      color: VaultedColors.textMuted,
                      letterSpacing: 4,
                    ),
                    filled: true,
                    fillColor: VaultedColors.bgInput,
                    border: OutlineInputBorder(
                      borderRadius: VaultedRadii.brInput,
                      borderSide:
                          const BorderSide(color: VaultedColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: VaultedRadii.brInput,
                      borderSide:
                          const BorderSide(color: VaultedColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: VaultedRadii.brInput,
                      borderSide: BorderSide(
                        color: _isConfirmed
                            ? VaultedColors.danger
                            : VaultedColors.accentGold,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(
                duration: 400.ms,
                delay: 200.ms,
                curve: Curves.easeOut,
              ),

          VaultedSpacing.gapXxl,

          // ── Delete Button ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConfirmed
                    ? VaultedColors.danger
                    : VaultedColors.danger.withValues(alpha: 0.15),
                foregroundColor:
                    _isConfirmed ? Colors.white : VaultedColors.textMuted,
                disabledBackgroundColor:
                    VaultedColors.danger.withValues(alpha: 0.15),
                disabledForegroundColor: VaultedColors.textMuted,
              ),
              onPressed:
                  _isConfirmed && !_isDeleting ? _performDeletion : null,
              child: _isDeleting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: VaultedSpacing.md),
                        Text(
                          'Deleting Account...',
                          style: VaultedTypography.buttonLabel(),
                        ),
                      ],
                    )
                  : const Text('Permanently Delete My Account'),
            ),
          )
              .animate()
              .fadeIn(
                duration: 400.ms,
                delay: 250.ms,
                curve: Curves.easeOut,
              ),

          VaultedSpacing.gapXxl,
        ],
      ),
    );
  }

  // ── Deletion flow ────────────────────────────────────────────────

  /// Calls the `deleteUserCascade` Cloud Function via Firebase callable SDK,
  /// then signs out.
  Future<void> _performDeletion() async {
    Haptics.heavyTap();
    setState(() => _isDeleting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _handleError('Not authenticated');
        return;
      }

      final callable = FirebaseFunctions.instance.httpsCallable(
        'deleteUserCascade',
      );
      await callable.call<dynamic>({});

      await FirebaseAuth.instance.signOut();

      Haptics.success();

      if (mounted) {
        context.go('/auth/welcome');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _handleError(
          'For security, please sign out and sign back in, then try again.',
        );
      } else {
        _handleError('Authentication error: ${e.message ?? 'Unknown error'}');
      }
    } on FirebaseFunctionsException catch (e) {
      _handleError(e.message ?? 'Deletion failed. Please try again.');
    } catch (e) {
      _handleError('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _handleError(String message) {
    Haptics.error();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
        ),
      );
  }
}

// ── Deletion item row ───────────────────────────────────────────────

class _DeletionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DeletionItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: VaultedColors.danger, size: 20),
        const SizedBox(width: VaultedSpacing.md),
        Expanded(
          child: Text(
            label,
            style: VaultedTypography.bodyLarge,
          ),
        ),
      ],
    );
  }
}
