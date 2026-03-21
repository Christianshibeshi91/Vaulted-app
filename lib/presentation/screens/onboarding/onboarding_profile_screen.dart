import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

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
  String? _avatarPath;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    Haptics.lightTap();
    // TODO: Use image_picker to pick avatar
    // final picker = ImagePicker();
    // final image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) setState(() => _avatarPath = image.path);
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) {
      Haptics.error();
      return;
    }
    Haptics.mediumTap();
    context.goNamed(RouteNames.onboardingSecurity);
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
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: VaultedColors.bgInput,
                        backgroundImage: _avatarPath != null
                            ? AssetImage(_avatarPath!)
                            : null,
                        child: _avatarPath == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 48,
                                color: VaultedColors.textMuted,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: VaultedColors.accentGold,
                            shape: BoxShape.circle,
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
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms).scale(
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
                  onPressed: _handleContinue,
                  child: const Text('Continue'),
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: isActive ? 24 : 8,
          height: 8,
          margin: EdgeInsets.only(right: i < total - 1 ? VaultedSpacing.sm : 0),
          decoration: BoxDecoration(
            color: isActive ? VaultedColors.accentGold : VaultedColors.bgInput,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
