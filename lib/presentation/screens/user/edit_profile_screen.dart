import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/auth_providers.dart';

/// Edit profile screen – update display name.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    Haptics.mediumTap();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');

      final newName = _nameController.text.trim();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'displayName': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth profile too.
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);

      // Refresh the user provider so the profile screen updates.
      ref.invalidate(currentUserProvider);

      if (mounted) {
        Haptics.success();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        Haptics.error();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: VaultedColors.accentGold,
                    ),
                  )
                : Text(
                    'Save',
                    style: VaultedTypography.bodyLarge.copyWith(
                      color: VaultedColors.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: VaultedColors.accentGold),
        ),
        error: (_, _) => const Center(child: Text('Failed to load')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          if (!_initialized) {
            _nameController.text = user.displayName ?? '';
            _initialized = true;
          }

          return ListView(
            padding: const EdgeInsets.all(VaultedSpacing.xl),
            children: [
              // Avatar display
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: VaultedColors.accentGold,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: VaultedColors.bgCard,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            _initials(user.displayName, user.email),
                            style: VaultedTypography.gold(
                              VaultedTypography.headlineLarge,
                            ).copyWith(fontSize: 28),
                          )
                        : null,
                  ),
                ),
              ),
              VaultedSpacing.gapXxl,

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISPLAY NAME',
                      style: VaultedTypography.labelSmall.copyWith(
                        color: VaultedColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    VaultedSpacing.gapSm,
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: VaultedTypography.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        filled: true,
                        fillColor: VaultedColors.bgCard,
                        border: OutlineInputBorder(
                          borderRadius: VaultedRadii.brButton,
                          borderSide: BorderSide(color: VaultedColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: VaultedRadii.brButton,
                          borderSide: BorderSide(color: VaultedColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: VaultedRadii.brButton,
                          borderSide: const BorderSide(
                            color: VaultedColors.accentGold,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    VaultedSpacing.gapXl,

                    // Email (read-only)
                    Text(
                      'EMAIL',
                      style: VaultedTypography.labelSmall.copyWith(
                        color: VaultedColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    VaultedSpacing.gapSm,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: VaultedSpacing.lg,
                        vertical: VaultedSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: VaultedColors.bgCard,
                        borderRadius: VaultedRadii.brButton,
                        border: Border.all(color: VaultedColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            color: VaultedColors.textMuted,
                            size: 22,
                          ),
                          const SizedBox(width: VaultedSpacing.md),
                          Text(
                            user.email,
                            style: VaultedTypography.bodyLarge.copyWith(
                              color: VaultedColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    VaultedSpacing.gapSm,
                    Text(
                      'Email cannot be changed',
                      style: VaultedTypography.labelSmall.copyWith(
                        color: VaultedColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _initials(String? name, String email) {
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }
}
