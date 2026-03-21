import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Data export and account deletion screen.
class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  bool _isExporting = false;
  final _deleteController = TextEditingController();

  @override
  void dispose() {
    _deleteController.dispose();
    super.dispose();
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    Haptics.mediumTap();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');

      final firestore = FirebaseFirestore.instance;

      // Fetch user data.
      final userDoc = await firestore.collection('users').doc(uid).get();

      // Fetch cards.
      final cardsSnap =
          await firestore.collection('users').doc(uid).collection('cards').get();

      // Fetch transactions.
      final txSnap = await firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .get();

      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'user': userDoc.data(),
        'cards': cardsSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        'transactions':
            txSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      };

      final jsonString =
          const JsonEncoder.withIndent('  ').convert(exportData);

      // Share as text.
      await Share.share(
        jsonString,
        subject: 'Vaulted Data Export',
      );

      if (mounted) {
        Haptics.success();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        Haptics.error();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showDeleteConfirmation() {
    Haptics.warning();
    _deleteController.clear();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VaultedColors.bgSecondary,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          VaultedSpacing.xl,
          VaultedSpacing.md,
          VaultedSpacing.xl,
          MediaQuery.of(ctx).viewInsets.bottom + VaultedSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: VaultedColors.danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: VaultedColors.danger,
                size: 28,
              ),
            ),
            VaultedSpacing.gapLg,
            Text(
              'Delete Account',
              style: VaultedTypography.headlineMedium.copyWith(
                color: VaultedColors.danger,
              ),
            ),
            VaultedSpacing.gapSm,
            Text(
              'This action is permanent and cannot be undone. All your data, cards, and transaction history will be permanently deleted.',
              style: VaultedTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            VaultedSpacing.gapXl,
            Text(
              'Type DELETE to confirm',
              style: VaultedTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            VaultedSpacing.gapMd,
            TextField(
              controller: _deleteController,
              textAlign: TextAlign.center,
              style: VaultedTypography.monoMedium.copyWith(
                color: VaultedColors.danger,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                hintText: 'DELETE',
                hintStyle: VaultedTypography.monoMedium.copyWith(
                  color: VaultedColors.textMuted,
                  letterSpacing: 4,
                ),
              ),
            ),
            VaultedSpacing.gapXxl,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultedColors.danger,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_deleteController.text.trim() == 'DELETE') {
                    Haptics.heavyTap();
                    Navigator.pop(ctx);
                    _performAccountDeletion();
                  } else {
                    Haptics.error();
                  }
                },
                child: const Text('Delete My Account'),
              ),
            ),
            VaultedSpacing.gapMd,
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performAccountDeletion() async {
    // In production:
    // 1. Call a Cloud Function to delete all subcollections
    // 2. Delete the user document
    // 3. Delete the Firebase Auth account
    // 4. Sign out and navigate to welcome screen
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deletion failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(title: const Text('Your Data')),
      body: ListView(
        padding: const EdgeInsets.all(VaultedSpacing.xl),
        children: [
          // Export section
          Container(
            padding: const EdgeInsets.all(VaultedSpacing.xl),
            decoration: BoxDecoration(
              color: VaultedColors.bgCard,
              borderRadius: VaultedRadii.brCard,
              border: Border.all(color: VaultedColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: VaultedColors.accentGoldDim,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.download_outlined,
                        color: VaultedColors.accentGold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: VaultedSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Export Data',
                              style: VaultedTypography.headlineMedium),
                          const SizedBox(height: 2),
                          Text(
                            'Download all your data as JSON',
                            style: VaultedTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                VaultedSpacing.gapXl,
                Text(
                  'Your export includes your profile, cards, and transaction history.',
                  style: VaultedTypography.bodyMedium,
                ),
                VaultedSpacing.gapLg,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportData,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: VaultedColors.bgPrimary,
                            ),
                          )
                        : const Icon(Icons.share_rounded, size: 18),
                    label: Text(_isExporting ? 'Exporting...' : 'Export & Share'),
                  ),
                ),
              ],
            ),
          ),

          VaultedSpacing.gapXxl,

          // Delete account section
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: VaultedColors.danger.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        color: VaultedColors.danger,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: VaultedSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Account',
                            style: VaultedTypography.headlineMedium.copyWith(
                              color: VaultedColors.danger,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Permanently remove your account',
                            style: VaultedTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                VaultedSpacing.gapXl,
                Text(
                  'This will permanently delete your account and all associated data. This action cannot be undone.',
                  style: VaultedTypography.bodyMedium,
                ),
                VaultedSpacing.gapLg,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          VaultedColors.danger.withValues(alpha: 0.15),
                      foregroundColor: VaultedColors.danger,
                    ),
                    onPressed: _showDeleteConfirmation,
                    child: const Text('Delete Account'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
