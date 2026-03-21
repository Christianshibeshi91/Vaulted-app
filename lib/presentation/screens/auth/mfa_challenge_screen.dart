import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Six-digit MFA code entry with auto-advance and auto-submit.
class MfaChallengeScreen extends StatefulWidget {
  const MfaChallengeScreen({super.key});

  @override
  State<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

class _MfaChallengeScreenState extends State<MfaChallengeScreen> {
  static const _codeLength = 6;

  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_codeLength, (_) => FocusNode());

  bool _isLoading = false;
  bool _showRecovery = false;
  final _recoveryController = TextEditingController();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _recoveryController.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    // Allow only single digit
    if (value.length > 1) {
      _controllers[index].text = value[value.length - 1];
    }

    if (value.isNotEmpty && index < _codeLength - 1) {
      // Advance to next field
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-submit when all 6 digits are entered
    if (_code.length == _codeLength &&
        _code.contains(RegExp(r'^\d{6}$'))) {
      _handleSubmit();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    final code = _code;
    if (code.length != _codeLength) {
      Haptics.error();
      return;
    }

    setState(() => _isLoading = true);
    Haptics.mediumTap();

    try {
      // TODO: Verify MFA code with Firebase
      await Future<void>.delayed(const Duration(seconds: 2));

      Haptics.success();
      // Navigation handled by auth state redirect
    } catch (e) {
      Haptics.error();
      // Clear all fields on failure
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid code. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRecoverySubmit() async {
    final code = _recoveryController.text.trim();
    if (code.isEmpty) {
      Haptics.error();
      return;
    }

    setState(() => _isLoading = true);
    Haptics.mediumTap();

    try {
      // TODO: Verify recovery code
      await Future<void>.delayed(const Duration(seconds: 2));
      Haptics.success();
    } catch (e) {
      Haptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid recovery code.')),
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

              const Spacer(),

              // -- Header --
              Center(
                child: Text(
                  'Two-Factor\nAuthentication',
                  textAlign: TextAlign.center,
                  style:
                      VaultedTypography.gold(VaultedTypography.displayMedium),
                ),
              ).animate().fadeIn(duration: 500.ms),

              VaultedSpacing.gapMd,

              Center(
                child: Text(
                  'Enter the 6-digit code from\nyour authenticator app',
                  textAlign: TextAlign.center,
                  style: VaultedTypography.bodyLarge.copyWith(
                    color: VaultedColors.textSecondary,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              VaultedSpacing.gapXxxl,

              // -- Code input or recovery --
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showRecovery
                    ? _buildRecoveryInput()
                    : _buildCodeInput(),
              ),

              VaultedSpacing.gapXxl,

              // -- Submit button (visible when recovery is shown) --
              if (_showRecovery)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRecoverySubmit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: VaultedColors.bgPrimary,
                            ),
                          )
                        : const Text('Verify Recovery Code'),
                  ),
                ),

              VaultedSpacing.gapXxl,

              // -- Toggle recovery / code --
              Center(
                child: TextButton(
                  onPressed: () {
                    Haptics.lightTap();
                    setState(() => _showRecovery = !_showRecovery);
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                  ),
                  child: Text(
                    _showRecovery
                        ? 'Use authenticator code instead'
                        : 'Use a recovery code instead',
                    style: VaultedTypography.bodyMedium.copyWith(
                      color: VaultedColors.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // -- Loading indicator --
              if (_isLoading && !_showRecovery)
                Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: VaultedColors.accentGold,
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

  Widget _buildCodeInput() {
    return Row(
      key: const ValueKey('code'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_codeLength, (i) {
        return Container(
          width: 48,
          height: 56,
          margin: EdgeInsets.only(
            right: i < _codeLength - 1 ? VaultedSpacing.sm : 0,
          ),
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(i, event),
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              onChanged: (v) => _onDigitChanged(i, v),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: VaultedTypography.monoHero.copyWith(fontSize: 24),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: VaultedColors.bgInput,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: VaultedColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: VaultedColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: VaultedColors.accentGold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Widget _buildRecoveryInput() {
    return Column(
      key: const ValueKey('recovery'),
      children: [
        TextFormField(
          controller: _recoveryController,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleRecoverySubmit(),
          autocorrect: false,
          style: VaultedTypography.monoMedium,
          decoration: const InputDecoration(
            labelText: 'Recovery Code',
            prefixIcon: Icon(Icons.vpn_key_outlined),
            hintText: 'XXXX-XXXX-XXXX',
          ),
        ),
      ],
    );
  }
}
