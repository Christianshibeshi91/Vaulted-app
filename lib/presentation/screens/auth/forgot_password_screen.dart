import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/validators.dart';

/// Forgot-password screen: enter email, send reset link, show success state.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  // Resend cooldown
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) {
      Haptics.error();
      return;
    }

    setState(() => _isLoading = true);
    Haptics.mediumTap();

    try {
      // TODO: Replace with FirebaseAuth.sendPasswordResetEmail
      await Future<void>.delayed(const Duration(seconds: 2));

      Haptics.success();
      setState(() => _emailSent = true);
      _startResendCooldown();
    } catch (e) {
      Haptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset link: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0) return;

    setState(() => _isLoading = true);
    Haptics.mediumTap();

    try {
      // TODO: Replace with FirebaseAuth.sendPasswordResetEmail
      await Future<void>.delayed(const Duration(seconds: 1));

      Haptics.success();
      _startResendCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset link resent.')),
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

              VaultedSpacing.gapXxxl,

              // -- Content (switches between form and success) --
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _emailSent ? _buildSuccess() : _buildForm(),
                ),
              ),

              // -- Back to Sign In --
              Center(
                child: TextButton(
                  onPressed: () {
                    Haptics.lightTap();
                    context.goNamed(RouteNames.authLogin);
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                  ),
                  child: Text(
                    'Back to Sign In',
                    style: VaultedTypography.bodyMedium.copyWith(
                      color: VaultedColors.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              VaultedSpacing.gapLg,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password',
          style: VaultedTypography.gold(VaultedTypography.displayMedium),
        ).animate().fadeIn(duration: 500.ms),

        VaultedSpacing.gapSm,

        Text(
          'Enter your email and we will send you\na link to reset your password.',
          style: VaultedTypography.bodyLarge.copyWith(
            color: VaultedColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

        VaultedSpacing.gapXxxl,

        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSendReset(),
            style: VaultedTypography.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
        ),

        VaultedSpacing.gapXxl,

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendReset,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: VaultedColors.bgPrimary,
                    ),
                  )
                : const Text('Send Reset Link'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      key: const ValueKey('success'),
      children: [
        const Spacer(),

        Icon(
          Icons.check_circle_outline_rounded,
          size: 72,
          color: VaultedColors.success,
        ).animate().fadeIn(duration: 500.ms).scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),

        VaultedSpacing.gapXxl,

        Text(
          'Check Your Email',
          style: VaultedTypography.gold(VaultedTypography.headlineLarge),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

        VaultedSpacing.gapMd,

        Text(
          'We sent a password reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: VaultedTypography.bodyLarge.copyWith(
            color: VaultedColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

        VaultedSpacing.gapXxxl,

        // Resend button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed:
                (_resendCooldown > 0 || _isLoading) ? null : _handleResend,
            style: OutlinedButton.styleFrom(
              foregroundColor: VaultedColors.accentGold,
              side: const BorderSide(color: VaultedColors.accentGold),
            ),
            child: Text(
              _resendCooldown > 0
                  ? 'Resend in $_resendCooldown s'
                  : 'Resend Link',
            ),
          ),
        ),

        const Spacer(flex: 2),
      ],
    );
  }
}
