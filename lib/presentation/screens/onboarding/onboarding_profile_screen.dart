import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/validators.dart';

/// Onboarding step 2: avatar picker and display name.
class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _avatarBytes;
  String? _avatarFileName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill display name from Firebase Auth if already set
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      _nameController.text = user.displayName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    Haptics.lightTap();
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (mounted) {
        setState(() {
          _avatarBytes = bytes;
          _avatarFileName = image.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not pick image')));
      }
    }
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      Haptics.error();
      return;
    }
    Haptics.mediumTap();
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    final displayName = _nameController.text.trim();

    // Save display name to Firebase Auth (always works for current user)
    try {
      if (user != null) {
        await user.updateDisplayName(displayName);
      }
    } catch (_) {
      // Non-blocking — continue anyway
    }

    // Upload avatar + save to Firestore in background (best-effort)
    if (user != null) {
      _saveProfileInBackground(user, displayName);
    }

    // Always navigate forward
    if (mounted) {
      context.goNamed(RouteNames.onboardingSecurity);
    }
  }

  /// Best-effort background save — avatar upload + Firestore write.
  /// Does not block navigation.
  Future<void> _saveProfileInBackground(User user, String displayName) async {
    try {
      String? avatarUrl;

      if (_avatarBytes != null) {
        final ext = (_avatarFileName?.split('.').last ?? 'jpg').toLowerCase();
        final ref = FirebaseStorage.instance
            .ref()
            .child('users')
            .child(user.uid)
            .child('avatar.$ext');
        await ref.putData(
          _avatarBytes!,
          SettableMetadata(contentType: 'image/$ext'),
        );
        avatarUrl = await ref.getDownloadURL();
        await user.updatePhotoURL(avatarUrl);
      }

      final profileData = <String, dynamic>{
        'displayName': displayName,
        'email': user.email ?? '',
      };
      if (avatarUrl != null) {
        profileData['avatarUrl'] = avatarUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));
    } catch (_) {
      // Silent — profile data will sync on next login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: VaultedSpacing.screenH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VaultedSpacing.gapLg,

              // -- Back --
              IconButton(
                onPressed: () {
                  Haptics.lightTap();
                  context.pop();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: VaultedColors.accentGold,
                ),
                style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
              ),

              VaultedSpacing.gapXxl,

              // -- Header --
              Text(
                'Set Up Your Profile',
                style: VaultedTypography.gold(VaultedTypography.displayMedium),
              ).animate().fadeIn(duration: 500.ms),

              VaultedSpacing.gapSm,

              Text(
                'Add a photo and display name',
                style: VaultedTypography.bodyLarge.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              VaultedSpacing.gapXxxl,

              // -- Avatar picker --
              Center(
                    child: GestureDetector(
                      onTap: _isSaving ? null : _pickAvatar,
                      child: Stack(
                        children: [
                          // Outer glow ring
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: VaultedColors.accentGold.withValues(
                                  alpha: 0.2,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: VaultedColors.bgInput,
                                backgroundImage: _avatarBytes != null
                                    ? MemoryImage(_avatarBytes!)
                                    : null,
                                child: _avatarBytes == null
                                    ? const Icon(
                                        Icons.person_rounded,
                                        size: 48,
                                        color: VaultedColors.textMuted,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: VaultedColors.accentGold,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: VaultedColors.accentGold.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 18,
                                color: VaultedColors.bgPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    delay: 300.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              VaultedSpacing.gapXxxl,

              // -- Name field --
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  validator: (v) => Validators.required(v, 'Display name'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleContinue(),
                  style: VaultedTypography.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
              ),

              const Spacer(),

              // -- Dot indicator (step 2 of 4) --
              _DotIndicator(current: 1, total: 4),

              VaultedSpacing.gapXxl,

              // -- Continue --
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleContinue,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: VaultedColors.bgPrimary,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),

              VaultedSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dot indicator ────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _DotIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        final isCompleted = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: isActive ? 24 : 8,
          height: 8,
          margin: EdgeInsets.only(right: i < total - 1 ? VaultedSpacing.sm : 0),
          decoration: BoxDecoration(
            color: isActive
                ? VaultedColors.accentGold
                : isCompleted
                ? VaultedColors.accentGold.withValues(alpha: 0.4)
                : VaultedColors.bgInput,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
