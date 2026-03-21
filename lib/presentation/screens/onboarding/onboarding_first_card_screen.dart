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

/// Onboarding step 4: add first gift card or skip.
class OnboardingFirstCardScreen extends StatefulWidget {
  const OnboardingFirstCardScreen({super.key});

  @override
  State<OnboardingFirstCardScreen> createState() =>
      _OnboardingFirstCardScreenState();
}

class _OnboardingFirstCardScreenState
    extends State<OnboardingFirstCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _balanceController = TextEditingController();

  String? _selectedRetailer;
  bool _isLoading = false;

  static const _retailers = [
    'Amazon',
    'Apple',
    'Best Buy',
    'Google Play',
    'Netflix',
    'Spotify',
    'Starbucks',
    'Target',
    'Visa',
    'Walmart',
    'Other',
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _handleAddCard() async {
    if (!_formKey.currentState!.validate()) {
      Haptics.error();
      return;
    }
    if (_selectedRetailer == null) {
      Haptics.warning();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a retailer.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    Haptics.mediumTap();

    try {
      // TODO: Save card to Firestore
      await Future<void>.delayed(const Duration(seconds: 1));

      Haptics.success();
      _finishOnboarding();
    } catch (e) {
      Haptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add card: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _finishOnboarding() {
    // TODO: Set onboardingComplete = true in Firestore
    context.goNamed(RouteNames.home);
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
                'Add Your First Card',
                style: VaultedTypography.gold(VaultedTypography.displayMedium),
              ).animate().fadeIn(duration: 500.ms),

              VaultedSpacing.gapSm,

              Text(
                'Store a gift card to get started',
                style: VaultedTypography.bodyLarge.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              VaultedSpacing.gapXxxl,

              // -- Retailer picker --
              Text(
                'Select Retailer',
                style: VaultedTypography.bodyMedium.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ),

              VaultedSpacing.gapMd,

              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _retailers.length,
                  separatorBuilder: (_, _) => VaultedSpacing.gapHSm,
                  itemBuilder: (_, i) {
                    final name = _retailers[i];
                    final selected = _selectedRetailer == name;
                    return GestureDetector(
                      onTap: () {
                        Haptics.selection();
                        setState(() => _selectedRetailer = name);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: VaultedSpacing.lg,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? VaultedColors.accentGoldDim
                              : VaultedColors.bgCard,
                          borderRadius: VaultedRadii.brPill,
                          border: Border.all(
                            color: selected
                                ? VaultedColors.accentGold
                                : VaultedColors.border,
                          ),
                        ),
                        child: Text(
                          name,
                          style: VaultedTypography.bodyMedium.copyWith(
                            color: selected
                                ? VaultedColors.accentGold
                                : VaultedColors.textSecondary,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              VaultedSpacing.gapXxl,

              // -- Card form --
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Card number
                    TextFormField(
                      controller: _cardNumberController,
                      validator: Validators.cardNumber,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: VaultedTypography.monoMedium,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        prefixIcon: Icon(Icons.credit_card_rounded),
                      ),
                    ),

                    VaultedSpacing.gapLg,

                    // Balance
                    TextFormField(
                      controller: _balanceController,
                      validator: (v) => Validators.amount(v),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleAddCard(),
                      style: VaultedTypography.monoMedium,
                      decoration: const InputDecoration(
                        labelText: 'Balance',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                        hintText: '0.00',
                      ),
                    ),
                  ],
                ),
              ),

              VaultedSpacing.gapXxxl,

              // -- Dot indicator (step 4 of 4) --
              _DotIndicator(current: 3, total: 4),

              VaultedSpacing.gapXxl,

              // -- Add Card button --
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAddCard,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: VaultedColors.bgPrimary,
                          ),
                        )
                      : const Text('Add Card'),
                ),
              ),

              VaultedSpacing.gapMd,

              // -- Skip --
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () {
                    Haptics.lightTap();
                    _finishOnboarding();
                  },
                  child: Text(
                    'Skip for now',
                    style: VaultedTypography.bodyLarge.copyWith(
                      color: VaultedColors.textMuted,
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
