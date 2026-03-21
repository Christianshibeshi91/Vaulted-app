import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Displays legal text (Terms of Service or Privacy Policy) in-app.
class LegalContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalContentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  /// Factory for the Terms of Service screen.
  factory LegalContentScreen.terms() => const LegalContentScreen(
        title: 'Terms of Service',
        content: _termsText,
      );

  /// Factory for the Privacy Policy screen.
  factory LegalContentScreen.privacy() => const LegalContentScreen(
        title: 'Privacy Policy',
        content: _privacyText,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: VaultedColors.bgPrimary,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(VaultedSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSections(),
        ),
      ),
    );
  }

  List<Widget> _buildSections() {
    final sections = content.split('\n\n');
    final widgets = <Widget>[];

    for (final section in sections) {
      final trimmed = section.trim();
      if (trimmed.isEmpty) continue;

      // Lines starting with "## " are section headers.
      if (trimmed.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: VaultedSpacing.xl),
          child: Text(
            trimmed.substring(3),
            style: VaultedTypography.headlineMedium,
          ),
        ));
        widgets.add(VaultedSpacing.gapMd);
      } else if (trimmed.startsWith('# ')) {
        // Top-level heading.
        widgets.add(Text(
          trimmed.substring(2),
          style: VaultedTypography.headlineLarge,
        ));
        widgets.add(VaultedSpacing.gapLg);
      } else {
        widgets.add(Text(
          trimmed,
          style: VaultedTypography.bodyMedium.copyWith(height: 1.6),
        ));
        widgets.add(VaultedSpacing.gapMd);
      }
    }

    // Bottom padding.
    widgets.add(const SizedBox(height: 60));
    return widgets;
  }
}

// ── Legal content ──────────────────────────────────────────────────────

const _termsText = '''
# Terms of Service

Last updated: March 2026

## 1. Acceptance of Terms

By accessing or using Vaulted ("the App"), you agree to be bound by these Terms of Service. If you do not agree to all of these terms, you may not use the App.

## 2. Description of Service

Vaulted is a digital gift card wallet that allows you to securely store, manage, and track your gift cards. The App provides features including card storage, balance tracking, transaction history, and data export.

## 3. Account Registration

You must provide accurate information when creating an account. You are responsible for maintaining the security of your account credentials. You must notify us immediately of any unauthorized use of your account.

## 4. User Responsibilities

You agree not to use the App for any unlawful purpose or in violation of these terms. You are solely responsible for the gift cards you store and their legitimacy. You must not attempt to gain unauthorized access to any part of the App or its systems.

## 5. Data and Privacy

Your use of the App is also governed by our Privacy Policy. We encrypt sensitive card data at rest and in transit. You may export or delete your data at any time through the App settings.

## 6. Intellectual Property

The App and its original content, features, and functionality are owned by Vaulted and are protected by international copyright, trademark, and other intellectual property laws.

## 7. Termination

We may terminate or suspend your account at any time without prior notice for conduct that we believe violates these Terms or is harmful to other users, us, or third parties. You may delete your account at any time through the App settings.

## 8. Limitation of Liability

Vaulted is provided "as is" without warranties of any kind. We are not liable for any loss of gift card data, balances, or any indirect, incidental, or consequential damages arising from your use of the App.

## 9. Changes to Terms

We reserve the right to modify these terms at any time. We will notify you of significant changes through the App. Continued use of the App after changes constitutes acceptance of the new terms.

## 10. Contact

If you have questions about these Terms, please contact us at support@vaulted.app.
''';

const _privacyText = '''
# Privacy Policy

Last updated: March 2026

## 1. Information We Collect

We collect information you provide directly: name, email address, and gift card data you choose to store. We also collect usage data such as app interactions, device information, and crash reports to improve the App.

## 2. How We Use Your Information

We use your information to provide and maintain the App, personalize your experience, send important notifications about your account, and improve our services. We do not sell your personal information to third parties.

## 3. Data Security

We implement industry-standard security measures to protect your data. Gift card details are encrypted using AES-256 encryption at rest. All data transmission uses TLS 1.3. We use Firebase Authentication for secure identity management.

## 4. Data Storage

Your data is stored on Google Cloud Platform servers. We retain your data for as long as your account is active. You can request data deletion at any time through the App settings.

## 5. Third-Party Services

We use the following third-party services: Firebase (authentication, database, storage, analytics), Google Cloud Platform (hosting), and crash reporting tools. Each service has its own privacy policy governing data handling.

## 6. Your Rights

You have the right to access your personal data at any time through the App. You can export all your data in JSON format from the App settings. You can request deletion of your account and all associated data. You can update your profile information at any time.

## 7. Cookies and Tracking

The App does not use browser cookies. We use Firebase Analytics to collect anonymous usage statistics. You can opt out of analytics through the App notification settings.

## 8. Children's Privacy

The App is not intended for users under the age of 13. We do not knowingly collect personal information from children under 13.

## 9. Changes to This Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy in the App and updating the "Last updated" date.

## 10. Contact Us

If you have questions about this Privacy Policy, please contact us at support@vaulted.app.
''';
