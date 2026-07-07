import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/balance_parser.dart';
import '../../../../core/utils/encryption.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../domain/entities/balance_result.dart';
import '../../domain/entities/retailer_config.dart';
import '../providers/balance_checker_providers.dart';
import '../screens/scan_card_screen.dart';
import '../services/balance_checker_service.dart';
import '../widgets/balance_loading_widget.dart';
import '../widgets/captcha_overlay_widget.dart';
import '../widgets/manual_balance_entry.dart';

/// Full-screen balance check flow for a selected retailer.
///
/// Handles:
/// - Card number + PIN input with validation
/// - WebView-based auto balance check (Phase 1 retailers)
/// - Redirect fallback with manual entry (Phase 2 retailers)
/// - CAPTCHA overlay when needed
/// - Saving the card to Firestore on success
class BalanceCheckScreen extends ConsumerStatefulWidget {
  const BalanceCheckScreen({
    super.key,
    required this.config,
  });

  final RetailerConfig config;

  @override
  ConsumerState<BalanceCheckScreen> createState() => _BalanceCheckScreenState();
}

class _BalanceCheckScreenState extends ConsumerState<BalanceCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _pinController = TextEditingController();

  _ScreenState _state = _ScreenState.input;
  BalanceCheckerService? _checkerService;
  double? _balance;
  String? _errorMessage;
  bool _showCaptcha = false;

  RetailerConfig get _config => widget.config;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _pinController.dispose();
    _checkerService?.dispose();
    super.dispose();
  }

  Future<void> _startBalanceCheck() async {
    if (!_formKey.currentState!.validate()) return;

    final cardNumber = _cardNumberController.text.trim();
    final pin = _pinController.text.trim();

    // Rate limiting
    final canCheck = ref.read(canCheckBalanceProvider(_config.id));
    if (!canCheck) {
      _showError('Please wait a few minutes before checking again');
      return;
    }

    setState(() {
      _state = _ScreenState.checking;
      _errorMessage = null;
      _showCaptcha = false;
    });

    await Haptics.lightTap();

    // On web, WebView balance scraping is impossible (iframe same-origin
    // policy + X-Frame-Options: DENY). Show a brief loading animation
    // then transition smoothly to manual entry.
    if (kIsWeb) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _state = _ScreenState.manualEntry;
        _errorMessage = null;
      });
      logBalanceCheckAnalytics(
        retailerId: _config.id,
        success: false,
        method: 'web_manual_fallback',
        durationMs: 800,
        captchaRequired: false,
      );
      return;
    }

    _checkerService = BalanceCheckerService(
      config: _config,
      onCaptchaRequired: () {
        setState(() => _showCaptcha = true);
        _checkerService?.hideChromeForCaptcha();
      },
    );

    final result = await _checkerService!.checkBalance(
      cardNumber: cardNumber,
      pin: pin,
    );

    // Record the check for rate limiting
    recordBalanceCheck(ref, _config.id);

    switch (result) {
      case BalanceSuccess(
          amount: final amount,
          durationMs: final ms,
          captchaWasRequired: final captcha,
        ):
        await Haptics.success();
        setState(() {
          _balance = amount;
          _state = _ScreenState.success;
          _showCaptcha = false;
        });
        // Log analytics
        logBalanceCheckAnalytics(
          retailerId: _config.id,
          success: true,
          method: 'webview',
          durationMs: ms,
          captchaRequired: captcha,
        );

      case BalanceError(message: final msg):
        await Haptics.error();
        setState(() {
          _state = _ScreenState.error;
          _errorMessage = _humanizeError(msg);
          _showCaptcha = false;
        });
        logBalanceCheckAnalytics(
          retailerId: _config.id,
          success: false,
          method: 'webview',
          durationMs: 0,
          captchaRequired: false,
        );

      case BalanceTimeout(durationMs: final ms):
        await Haptics.error();
        setState(() {
          _state = _ScreenState.error;
          _errorMessage =
              'Balance check timed out. The retailer may be slow — try again.';
          _showCaptcha = false;
        });
        logBalanceCheckAnalytics(
          retailerId: _config.id,
          success: false,
          method: 'webview',
          durationMs: ms,
          captchaRequired: false,
        );

      case BalanceCaptchaRequired():
        // Handled by the onCaptchaRequired callback
        break;
    }

    await _checkerService?.dispose();
    _checkerService = null;
  }

  Future<void> _saveCard(double balance) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final cardNumber = _cardNumberController.text.trim();
    final pin = _pinController.text.trim();
    final now = DateTime.now();
    final id = const Uuid().v4();

    final cardData = <String, dynamic>{
      'id': id,
      'retailer': _config.name,
      'retailerColor': _config.brandColor,
      'balance': balance,
      'originalBalance': balance,
      'currency': 'USD',
      'status': 'active',
      'addedVia': _config.supportsWebView ? 'balance_check' : 'manual',
      'lastBalanceCheck': Timestamp.fromDate(now),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    // Encrypt card number and PIN before storing
    final encryptionService = EncryptionService(SecureStorageService.instance);
    await encryptionService.initialise();

    if (cardNumber.isNotEmpty) {
      cardData['cardNumberEncrypted'] = encryptionService.encrypt(cardNumber);
    }
    if (pin.isNotEmpty) {
      cardData['pinEncrypted'] = encryptionService.encrypt(pin);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cards')
        .doc(id)
        .set(cardData);

    await Haptics.success();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Card added to your vault',
            style: VaultedTypography.bodyMedium.copyWith(
              color: VaultedColors.textPrimary,
            ),
          ),
          backgroundColor: VaultedColors.bgCard,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: VaultedTypography.bodyMedium
                .copyWith(color: VaultedColors.danger)),
        backgroundColor: VaultedColors.bgCard,
      ),
    );
  }

  String _humanizeError(String code) {
    final name = _config.name;
    final loginRequired = _config.requiresRedirect;

    if (code == 'CARD_FIELD_NOT_FOUND' && loginRequired) {
      return '$name requires login to check balances. Enter your balance manually below.';
    }

    return switch (code) {
      'WEB_UNSUPPORTED' =>
        'Auto-check is not available in the browser. Enter your balance manually below.',
      'CARD_FIELD_NOT_FOUND' =>
        'Could not find the balance check form on $name\'s page. You can enter your balance manually below.',
      'INVALID_CARD' =>
        '$name says this card number or PIN is invalid. Double-check your details.',
      'TIMEOUT' =>
        '$name\'s page took too long to respond. Enter your balance manually below.',
      'CAPTCHA_TIMEOUT' =>
        'The verification timed out. Enter your balance manually below.',
      _ => 'Auto-check didn\'t work for $name. Enter your balance manually below.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: VaultedColors.bgPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'ADD ${_config.name.toUpperCase()} CARD',
          style: VaultedTypography.labelSmall.copyWith(
            color: VaultedColors.textPrimary,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: VaultedSpacing.screenH,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VaultedSpacing.gapLg,
                  _buildRetailerHeader(),
                  VaultedSpacing.gapXxl,
                  if (_state == _ScreenState.input) _buildInputForm(),
                  if (_state == _ScreenState.checking) _buildCheckingState(),
                  if (_state == _ScreenState.success) _buildSuccessState(),
                  if (_state == _ScreenState.error) _buildErrorState(),
                  if (_state == _ScreenState.manualEntry) _buildManualEntryState(),
                  VaultedSpacing.gapXxxl,
                ],
              ),
            ),
          ),

          // Hidden WebView (zero height, required for JS execution)
          // Skipped on web — iframes cannot cross-origin inject JS.
          if (!kIsWeb &&
              _checkerService?.webViewManager?.controller != null &&
              !_showCaptcha)
            Positioned(
              left: 0,
              right: 0,
              bottom: -500,
              height: 1,
              child: WebViewWidget(
                controller:
                    _checkerService!.webViewManager!.controller!,
              ),
            ),

          // CAPTCHA overlay (not applicable on web)
          if (!kIsWeb && _showCaptcha)
            CaptchaOverlayWidget(
              controller:
                  _checkerService?.webViewManager?.controller,
              isVisible: _showCaptcha,
              onDismiss: () {
                setState(() => _showCaptcha = false);
                _checkerService?.dispose();
                _checkerService = null;
                setState(() {
                  _state = _ScreenState.error;
                  _errorMessage = 'Verification was cancelled';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRetailerHeader() {
    final color = _parseColor(_config.brandColor);
    return Container(
      padding: VaultedSpacing.cardInner,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _config.name[0].toUpperCase(),
                style: VaultedTypography.headlineLarge.copyWith(
                  color: color,
                ),
              ),
            ),
          ),
          VaultedSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _config.name,
                  style: VaultedTypography.headlineMedium,
                ),
                VaultedSpacing.gapXs,
                Builder(builder: (_) {
                  // On web, auto-check is never available regardless
                  // of retailer config.
                  final canAutoCheck =
                      !kIsWeb && _config.supportsWebView;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: canAutoCheck
                          ? VaultedColors.success.withValues(alpha: 0.12)
                          : VaultedColors.warning.withValues(alpha: 0.12),
                      borderRadius: VaultedRadii.brBadge,
                    ),
                    child: Text(
                      canAutoCheck ? 'Auto-check' : 'Manual',
                      style: VaultedTypography.labelSmall.copyWith(
                        color: canAutoCheck
                            ? VaultedColors.success
                            : VaultedColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardInputFields(),
          VaultedSpacing.gapXxl,

          // Check Balance button — shown for ALL retailers
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startBalanceCheck,
              child: Text(
                'Check Balance',
                style: VaultedTypography.buttonLabel(),
              ),
            ),
          ),
          VaultedSpacing.gapMd,

          // Or enter manually link
          Center(
            child: TextButton(
              onPressed: () {
                setState(() => _state = _ScreenState.manualEntry);
              },
              child: Text(
                'Or enter balance manually',
                style: VaultedTypography.bodyMedium.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanCard() async {
    final scannedNumber = await ScanCardScreen.show(context);
    if (scannedNumber != null && mounted) {
      _cardNumberController.text = scannedNumber;
      await Haptics.success();
    }
  }

  Widget _buildCardInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Number with scan button — accepts letters, dashes, numbers
        TextFormField(
          controller: _cardNumberController,
          style: VaultedTypography.monoMedium,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: 'Enter card number',
            prefixIcon: const Icon(Icons.credit_card, size: 20),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: VaultedColors.accentGold,
                size: 20,
              ),
              onPressed: _scanCard,
              tooltip: 'Scan card',
            ),
          ),
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-\s]')),
            LengthLimitingTextInputFormatter(30),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Card number is required';
            }
            return null;
          },
        ),
        VaultedSpacing.gapLg,

        // PIN (always shown, never required)
        TextFormField(
          controller: _pinController,
          style: VaultedTypography.monoMedium,
          decoration: const InputDecoration(
            labelText: 'PIN',
            hintText: 'Enter PIN (if applicable)',
            prefixIcon: Icon(Icons.lock_outline, size: 20),
          ),
          obscureText: true,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(12),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms, curve: Curves.easeOut);
  }

  Widget _buildCheckingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: VaultedSpacing.section),
        child: BalanceLoadingWidget(
          statusText: _showCaptcha
              ? 'Waiting for verification...'
              : 'Checking your balance...',
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        VaultedSpacing.gapLg,
        const BalanceLoadingWidget(
          isComplete: true,
          statusText: 'Balance found!',
        ),
        VaultedSpacing.gapXxl,

        // Balance display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: VaultedSpacing.xxl,
            horizontal: VaultedSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: VaultedColors.bgCard,
            borderRadius: VaultedRadii.brCard,
            border: Border.all(
              color: VaultedColors.accentGold.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                'CURRENT BALANCE',
                style: VaultedTypography.labelSmall.copyWith(
                  color: VaultedColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              VaultedSpacing.gapSm,
              Text(
                BalanceParser.format(_balance ?? 0),
                style: VaultedTypography.displayLarge.copyWith(
                  color: VaultedColors.accentGold,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms, curve: Curves.easeOut)
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              duration: 400.ms,
              delay: 300.ms,
              curve: Curves.easeOut,
            ),
        VaultedSpacing.gapXxl,

        // Save to vault button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _saveCard(_balance!),
            child: Text(
              'Add to Vault',
              style: VaultedTypography.buttonLabel(),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 500.ms, curve: Curves.easeOut),
        VaultedSpacing.gapMd,

        // Try again link
        TextButton(
          onPressed: () {
            setState(() {
              _state = _ScreenState.input;
              _balance = null;
            });
          },
          child: Text(
            'Check again',
            style: VaultedTypography.bodyMedium.copyWith(
              color: VaultedColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        VaultedSpacing.gapXxl,
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: VaultedColors.danger.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            color: VaultedColors.danger,
            size: 32,
          ),
        ),
        VaultedSpacing.gapLg,
        Text(
          _errorMessage ?? 'Something went wrong',
          style: VaultedTypography.bodyLarge.copyWith(
            color: VaultedColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        VaultedSpacing.gapXxl,

        // Manual balance entry — always shown on error
        ManualBalanceEntry(
          message: 'Enter your ${_config.name} balance manually.',
          onBalanceEntered: (balance) => _saveCard(balance),
        ),
        VaultedSpacing.gapLg,

        // Retry button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _state = _ScreenState.input;
                _errorMessage = null;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: VaultedColors.textSecondary,
              side: const BorderSide(color: VaultedColors.border),
              shape: VaultedRadii.shapeButton,
            ),
            child: const Text('Try Auto-Check Again'),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildManualEntryState() {
    final isWeb = kIsWeb;
    final message = isWeb
        ? 'Auto-check is not available in the browser. '
            'Visit ${_config.name}\'s website to check your balance, '
            'then enter it below.'
        : 'Enter your ${_config.name} card balance.';

    return Column(
      children: [
        VaultedSpacing.gapLg,
        if (isWeb) ...[
          Container(
            width: double.infinity,
            padding: VaultedSpacing.cardInner,
            decoration: BoxDecoration(
              color: VaultedColors.warning.withValues(alpha: 0.08),
              borderRadius: VaultedRadii.brCard,
              border: Border.all(
                color: VaultedColors.warning.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  color: VaultedColors.warning,
                  size: 20,
                ),
                VaultedSpacing.gapHSm,
                Expanded(
                  child: Text(
                    'Auto-check requires the mobile app. '
                    'Use the Vaulted app on iOS or Android for automatic balance checking.',
                    style: VaultedTypography.bodyMedium.copyWith(
                      color: VaultedColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, curve: Curves.easeOut),
          VaultedSpacing.gapLg,
        ],
        ManualBalanceEntry(
          message: message,
          onBalanceEntered: (balance) => _saveCard(balance),
        ),
        VaultedSpacing.gapMd,
        TextButton(
          onPressed: () {
            setState(() => _state = _ScreenState.input);
          },
          child: Text(
            'Back to card entry',
            style: VaultedTypography.bodyMedium.copyWith(
              color: VaultedColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return VaultedColors.textMuted;
  }
}

enum _ScreenState { input, checking, success, error, manualEntry }
