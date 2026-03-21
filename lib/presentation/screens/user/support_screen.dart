import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Help & Support screen with searchable FAQs and contact options.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _searchController = TextEditingController();
  final _feedbackController = TextEditingController();
  String _searchQuery = '';

  static const _faqs = <_FaqItem>[
    _FaqItem(
      question: 'How do I add a gift card?',
      answer:
          'Tap the + button on the Cards tab to add a new card. '
          'You can enter the card number, PIN, retailer, and balance manually, '
          'or scan the barcode using your camera.',
    ),
    _FaqItem(
      question: 'How do I check my card balance?',
      answer:
          'Open any card from your vault and tap "Update Balance". '
          'For supported retailers, Vaulted can check the balance automatically. '
          'Otherwise, visit the retailer\'s website or call the number on the back of the card.',
    ),
    _FaqItem(
      question: 'Is my card data secure?',
      answer:
          'Absolutely. All sensitive data (card numbers, PINs) is encrypted '
          'with AES-256-CBC before being stored. Your vault is protected by '
          'biometric authentication and automatic screen-capture prevention '
          'on sensitive screens.',
    ),
    _FaqItem(
      question: 'How do I delete my account?',
      answer:
          'Go to Profile > Data > Delete Account. You will be asked to '
          'type DELETE to confirm. This permanently removes all your data, '
          'cards, and transaction history. We recommend exporting your data first.',
    ),
    _FaqItem(
      question: 'Can I export my data?',
      answer:
          'Yes. Go to Profile > Data > Export Data to download a JSON file '
          'containing your profile, all cards, and transaction history. '
          'You can share or save this file for your records.',
    ),
    _FaqItem(
      question: 'How do I contact support?',
      answer:
          'Send us an email at ${AppConstants.supportEmail}. '
          'We aim to respond within 24 hours on business days. '
          'You can also use the Send Feedback option below for quick suggestions.',
    ),
    _FaqItem(
      question: 'What happens when a card is depleted?',
      answer:
          'When a card\'s balance reaches zero after a purchase, it is '
          'automatically marked as "Depleted". Depleted cards remain in '
          'your vault for record-keeping but can no longer be used for purchases.',
    ),
    _FaqItem(
      question: 'Can I share a card with someone?',
      answer:
          'Currently, card sharing is not supported to maintain security. '
          'Each card belongs to a single vault. We are exploring secure '
          'sharing options for a future update.',
    ),
  ];

  List<_FaqItem> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    final query = _searchQuery.toLowerCase();
    return _faqs
        .where((faq) =>
            faq.question.toLowerCase().contains(query) ||
            faq.answer.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: VaultedColors.bgPrimary,
        title: Text('Help & Support', style: VaultedTypography.headlineLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // ── Search Bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: VaultedSpacing.xl,
              vertical: VaultedSpacing.md,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: VaultedTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                hintStyle: VaultedTypography.bodyMedium,
                prefixIcon: const Icon(
                  Icons.search,
                  color: VaultedColors.textSecondary,
                  size: 22,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: VaultedColors.textSecondary,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: VaultedColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius: VaultedRadii.brInput,
                  borderSide: const BorderSide(color: VaultedColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: VaultedRadii.brInput,
                  borderSide: const BorderSide(color: VaultedColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: VaultedRadii.brInput,
                  borderSide: const BorderSide(
                    color: VaultedColors.accentGold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut),

          // ── FAQ Section ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VaultedSpacing.xl,
              VaultedSpacing.lg,
              VaultedSpacing.xl,
              VaultedSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: VaultedColors.accentGold.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(width: VaultedSpacing.sm),
                Text(
                  'FREQUENTLY ASKED QUESTIONS',
                  style: VaultedTypography.labelSmall.copyWith(
                    color: VaultedColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          if (_filteredFaqs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VaultedSpacing.xl,
                vertical: VaultedSpacing.xxl,
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      color: VaultedColors.textMuted,
                      size: 32,
                    ),
                    VaultedSpacing.gapSm,
                    Text(
                      'No matching questions found',
                      style: VaultedTypography.secondary(
                          VaultedTypography.bodyMedium),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_filteredFaqs.length, (index) {
              final faq = _filteredFaqs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: VaultedSpacing.sm),
                  decoration: BoxDecoration(
                    color: VaultedColors.bgCard,
                    borderRadius: VaultedRadii.brCard,
                    border: Border.all(color: VaultedColors.border),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      splashColor: VaultedColors.accentGoldDim,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: VaultedSpacing.lg,
                        vertical: VaultedSpacing.xs,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(
                        VaultedSpacing.lg,
                        0,
                        VaultedSpacing.lg,
                        VaultedSpacing.lg,
                      ),
                      iconColor: VaultedColors.accentGold,
                      collapsedIconColor: VaultedColors.textMuted,
                      title: Text(
                        faq.question,
                        style: VaultedTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      children: [
                        Text(
                          faq.answer,
                          style: VaultedTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: 200.ms,
                      delay: (40 * index).ms,
                      curve: Curves.easeOut,
                    )
                    .slideX(
                      begin: 0.03,
                      end: 0,
                      duration: 200.ms,
                      delay: (40 * index).ms,
                      curve: Curves.easeOut,
                    ),
              );
            }),

          VaultedSpacing.gapXxl,

          // ── Contact Section ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VaultedSpacing.xl,
              0,
              VaultedSpacing.xl,
              VaultedSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: VaultedColors.accentGold.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(width: VaultedSpacing.sm),
                Text(
                  'CONTACT US',
                  style: VaultedTypography.labelSmall.copyWith(
                    color: VaultedColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: VaultedSpacing.xl),
            child: Container(
              padding: VaultedSpacing.cardInner,
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
                        decoration: const BoxDecoration(
                          color: VaultedColors.accentGoldDim,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: VaultedColors.accentGold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: VaultedSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Support',
                              style: VaultedTypography.headlineMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppConstants.supportEmail,
                              style: VaultedTypography.gold(
                                  VaultedTypography.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  VaultedSpacing.gapMd,
                  Text(
                    'We typically respond within 24 hours on business days.',
                    style: VaultedTypography.bodyMedium,
                  ),
                  VaultedSpacing.gapLg,
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchEmail(),
                      icon: const Icon(Icons.send_outlined, size: 18),
                      label: const Text('Send Email'),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(
                  duration: 400.ms,
                  delay: 200.ms,
                  curve: Curves.easeOut,
                ),
          ),

          VaultedSpacing.gapXxl,

          // ── Send Feedback ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: VaultedSpacing.xl),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Haptics.lightTap();
                  _showFeedbackSheet();
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Send Feedback'),
              ),
            ),
          )
              .animate()
              .fadeIn(
                duration: 400.ms,
                delay: 300.ms,
                curve: Curves.easeOut,
              ),
        ],
      ),
    );
  }

  // ── Email launcher ───────────────────────────────────────────────

  Future<void> _launchEmail() async {
    Haptics.lightTap();
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      queryParameters: {'subject': 'Vaulted Support Request'},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email client')),
      );
    }
  }

  // ── Feedback bottom sheet ────────────────────────────────────────

  void _showFeedbackSheet() {
    _feedbackController.clear();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VaultedColors.bgSecondary,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: VaultedRadii.brBottomSheet,
      ),
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
              decoration: const BoxDecoration(
                color: VaultedColors.accentGoldDim,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: VaultedColors.accentGold,
                size: 28,
              ),
            ),
            VaultedSpacing.gapLg,
            Text(
              'Send Feedback',
              style: VaultedTypography.headlineMedium,
            ),
            VaultedSpacing.gapSm,
            Text(
              'Tell us what you think, report a bug, or suggest a feature.',
              style: VaultedTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            VaultedSpacing.gapXl,
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              maxLength: 500,
              style: VaultedTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Your feedback...',
                hintStyle: VaultedTypography.bodyMedium,
                filled: true,
                fillColor: VaultedColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius: VaultedRadii.brInput,
                  borderSide:
                      const BorderSide(color: VaultedColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: VaultedRadii.brInput,
                  borderSide:
                      const BorderSide(color: VaultedColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: VaultedRadii.brInput,
                  borderSide: const BorderSide(
                    color: VaultedColors.accentGold,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            VaultedSpacing.gapXxl,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final text = _feedbackController.text.trim();
                  if (text.isEmpty) {
                    Haptics.error();
                    return;
                  }
                  Haptics.success();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                        content:
                            Text('Thank you for your feedback!'),
                      ),
                    );
                },
                child: const Text('Submit'),
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
}

// ── FAQ data model ──────────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
