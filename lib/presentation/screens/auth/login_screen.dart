import 'dart:async';

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

/// Login screen with email/password, lockout logic, and social options.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _showShake = false;

  // Lockout state
  int _failedAttempts = 0;
  static const _maxAttempts = 5;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  bool get _isLockedOut => _lockoutSeconds > 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startLockoutTimer() {
    _lockoutSeconds = 30;
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lockoutSeconds--;
        if (_lockoutSeconds <= 0) {
          timer.cancel();
          _failedAttempts = 0;
        }
      });
    });
  }

  Future<void> _handleSignIn() async {
    if (_isLockedOut) return;
    if (!_formKey.currentState!.validate()) {
      Haptics.error();
      setState(() => _showShake = true);
      Future.delayed(600.ms, () {
        if (mounted) setState(() => _showShake = false);
      });
      return;
    }

    setState(() => _isLoading = true);
    Haptics.mediumTap();

    try {
      // TODO: Replace with FirebaseAuth.signInWithEmailAndPassword
      await Future<void>.delayed(const Duration(seconds: 2));

      // Simulate failure for demonstration; remove in production.
      _failedAttempts++;
      if (_failedAttempts >= _maxAttempts) {
        _startLockoutTimer();
        Haptics.error();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Too many attempts. Try again in 30 seconds.'),
            ),
          );
        }
      } else {
        Haptics.error();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password.')),
          );
          setState(() => _showShake = true);
          Future.delayed(600.ms, () {
            if (mounted) setState(() => _showShake = false);
          });
        }
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

              // -- Back button --
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

              VaultedSpacing.gapXxxl,

              // -- Header --
              Text(
                'Welcome Back',
                style: VaultedTypography.gold(VaultedTypography.displayMedium),
              ).animate().fadeIn(duration: 500.ms),

              VaultedSpacing.gapSm,

              Text(
                'Sign in to your vault',
                style: VaultedTypography.bodyLarge.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              VaultedSpacing.gapXxxl,

              // -- Form --
              Form(
                key: _formKey,
                child: _buildFormContent(),
              ),

              VaultedSpacing.gapXxl,

              // -- Social buttons --
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

              // -- Sign up link --
              Center(
                child: GestureDetector(
                  onTap: () {
                    Haptics.lightTap();
                    context.goNamed(RouteNames.authRegister);
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: VaultedTypography.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Sign Up',
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

  Widget _buildFormContent() {
    Widget formBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSignIn(),
          style: VaultedTypography.bodyLarge,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () {
                Haptics.lightTap();
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
            ),
          ),
        ),

        VaultedSpacing.gapLg,

        // Remember me + Forgot password
        Row(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Switch(
                      value: _rememberMe,
                      onChanged: (v) {
                        Haptics.toggle();
                        setState(() => _rememberMe = v);
                      },
                    ),
                  ),
                  VaultedSpacing.gapHSm,
                  Text(
                    'Remember me',
                    style: VaultedTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Haptics.lightTap();
                context.goNamed(RouteNames.authForgotPassword);
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
              ),
              child: Text(
                'Forgot Password?',
                style: VaultedTypography.bodyMedium.copyWith(
                  color: VaultedColors.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        VaultedSpacing.gapXxl,

        // Sign In button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: (_isLoading || _isLockedOut) ? null : _handleSignIn,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: VaultedColors.bgPrimary,
                    ),
                  )
                : Text(
                    _isLockedOut
                        ? 'Locked ($_lockoutSeconds s)'
                        : 'Sign In',
                  ),
          ),
        ),
      ],
    );

    // Wrap in shake animation on error
    if (_showShake) {
      formBody = formBody
          .animate()
          .shakeX(duration: 500.ms, hz: 4, amount: 6);
    }

    return formBody;
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
