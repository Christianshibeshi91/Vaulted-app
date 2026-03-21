import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/validators.dart';

/// Registration screen with password strength meter and requirements checklist.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final strength = Validators.passwordStrength(_passwordController.text);
    if (strength != _passwordStrength) {
      setState(() => _passwordStrength = strength);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      Haptics.error();
      return;
    }
    if (!_agreedToTerms) {
      Haptics.warning();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms of Service.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Haptics.mediumTap();

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await credential.user?.updateDisplayName(_nameController.text.trim());

      Haptics.success();
      if (mounted) {
        context.goNamed(RouteNames.onboarding);
      }
    } on FirebaseAuthException catch (_) {
      Haptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
          ),
        );
      }
    } catch (_) {
      Haptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
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
                'Create Account',
                style: VaultedTypography.gold(VaultedTypography.displayMedium),
              ).animate().fadeIn(duration: 500.ms),

              VaultedSpacing.gapSm,

              Text(
                'Start securing your gift cards',
                style: VaultedTypography.bodyLarge.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              VaultedSpacing.gapXxxl,

              // -- Form --
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display name
                    TextFormField(
                      controller: _nameController,
                      validator: (v) =>
                          Validators.required(v, 'Display name'),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      style: VaultedTypography.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),

                    VaultedSpacing.gapLg,

                    // Email
                    TextFormField(
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      style: VaultedTypography.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                    ),

                    VaultedSpacing.gapLg,

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      validator: Validators.password,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      style: VaultedTypography.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            Haptics.lightTap();
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(44, 44),
                          ),
                        ),
                      ),
                    ),

                    VaultedSpacing.gapMd,

                    // Password strength meter
                    _PasswordStrengthMeter(strength: _passwordStrength),

                    VaultedSpacing.gapMd,

                    // Requirements checklist
                    _PasswordRequirements(
                      password: _passwordController.text,
                    ),

                    VaultedSpacing.gapLg,

                    // Confirm password
                    TextFormField(
                      controller: _confirmController,
                      validator: (v) => Validators.confirmPassword(
                        v,
                        _passwordController.text,
                      ),
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleRegister(),
                      style: VaultedTypography.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            Haptics.lightTap();
                            setState(
                                () => _obscureConfirm = !_obscureConfirm);
                          },
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(44, 44),
                          ),
                        ),
                      ),
                    ),

                    VaultedSpacing.gapXxl,

                    // Terms checkbox
                    GestureDetector(
                      onTap: () {
                        Haptics.toggle();
                        setState(() => _agreedToTerms = !_agreedToTerms);
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (v) {
                                Haptics.toggle();
                                setState(
                                    () => _agreedToTerms = v ?? false);
                              },
                              activeColor: VaultedColors.accentGold,
                              checkColor: VaultedColors.bgPrimary,
                              side: const BorderSide(
                                color: VaultedColors.borderStrong,
                              ),
                            ),
                          ),
                          VaultedSpacing.gapHSm,
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the ',
                                style: VaultedTypography.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style:
                                        VaultedTypography.bodyMedium.copyWith(
                                      color: VaultedColors.accentGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style:
                                        VaultedTypography.bodyMedium.copyWith(
                                      color: VaultedColors.accentGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    VaultedSpacing.gapXxl,

                    // Create Account button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: VaultedColors.bgPrimary,
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                    ),
                  ],
                ),
              ),

              VaultedSpacing.gapXxl,

              // -- Social --
              _OrDivider(),
              VaultedSpacing.gapXxl,
              _SocialRow(
                onGoogle: () {
                  Haptics.mediumTap();
                  // TODO: Google sign-in
                },
                onApple: () {
                  Haptics.mediumTap();
                  // TODO: Apple sign-in
                },
              ),

              VaultedSpacing.gapXxl,

              // -- Already have account --
              Center(
                child: GestureDetector(
                  onTap: () {
                    Haptics.lightTap();
                    context.goNamed(RouteNames.authLogin);
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: VaultedTypography.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: VaultedTypography.bodyMedium.copyWith(
                            color: VaultedColors.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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

// ── Password strength meter (4 segments) ─────────────────────────────

class _PasswordStrengthMeter extends StatelessWidget {
  final int strength;

  const _PasswordStrengthMeter({required this.strength});

  Color _colorForSegment(int index) {
    if (index >= strength) return VaultedColors.bgInput;
    return switch (strength) {
      1 => VaultedColors.danger,
      2 => VaultedColors.warning,
      3 => VaultedColors.accentGold,
      4 => VaultedColors.success,
      _ => VaultedColors.bgInput,
    };
  }

  @override
  Widget build(BuildContext context) {
    final label = Validators.passwordStrengthLabel(strength);
    final labelColor = switch (strength) {
      1 => VaultedColors.danger,
      2 => VaultedColors.warning,
      3 => VaultedColors.accentGold,
      4 => VaultedColors.success,
      _ => VaultedColors.textMuted,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? VaultedSpacing.xs : 0),
                decoration: BoxDecoration(
                  color: _colorForSegment(i),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (label.isNotEmpty) ...[
          VaultedSpacing.gapXs,
          Text(
            label,
            style: VaultedTypography.labelSmall.copyWith(color: labelColor),
          ),
        ],
      ],
    );
  }
}

// ── Password requirements checklist ──────────────────────────────────

class _PasswordRequirements extends StatelessWidget {
  final String password;

  const _PasswordRequirements({required this.password});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RequirementRow(
          label: 'At least 8 characters',
          met: password.length >= 8,
        ),
        _RequirementRow(
          label: 'Uppercase letter',
          met: password.contains(RegExp(r'[A-Z]')),
        ),
        _RequirementRow(
          label: 'Lowercase letter',
          met: password.contains(RegExp(r'[a-z]')),
        ),
        _RequirementRow(
          label: 'Number',
          met: password.contains(RegExp(r'[0-9]')),
        ),
        _RequirementRow(
          label: 'Special character',
          met: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
        ),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool met;

  const _RequirementRow({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VaultedSpacing.xs),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              met ? Icons.check_circle_rounded : Icons.circle_outlined,
              key: ValueKey(met),
              size: 16,
              color: met ? VaultedColors.success : VaultedColors.textMuted,
            ),
          ),
          VaultedSpacing.gapHSm,
          Text(
            label,
            style: VaultedTypography.labelSmall.copyWith(
              color: met ? VaultedColors.success : VaultedColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ───────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: VaultedColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.lg),
          child: Text(
            'or continue with',
            style: VaultedTypography.labelSmall.copyWith(
              color: VaultedColors.textMuted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: VaultedColors.border)),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  const _SocialRow({required this.onGoogle, required this.onApple});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onGoogle,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
              label: const Text('Google'),
              style: OutlinedButton.styleFrom(
                foregroundColor: VaultedColors.textPrimary,
                backgroundColor: VaultedColors.bgInput,
                side: const BorderSide(color: VaultedColors.border),
                shape: VaultedRadii.shapeButton,
              ),
            ),
          ),
        ),
        VaultedSpacing.gapHMd,
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onApple,
              icon: const Icon(Icons.apple_rounded, size: 24),
              label: const Text('Apple'),
              style: OutlinedButton.styleFrom(
                foregroundColor: VaultedColors.textPrimary,
                backgroundColor: VaultedColors.bgInput,
                side: const BorderSide(color: VaultedColors.border),
                shape: VaultedRadii.shapeButton,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
