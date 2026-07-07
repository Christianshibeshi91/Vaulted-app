import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/theme/app_theme.dart';
import 'package:vaulted/presentation/screens/user/support_screen.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    theme: VaultedTheme.dark,
    home: child,
  );
}

/// Scrolls until [finder] is visible, using the first [Scrollable] found.
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder, {
  double delta = -200.0,
  int maxScrolls = 20,
}) async {
  for (var i = 0; i < maxScrolls; i++) {
    if (tester.any(finder)) return;
    await tester.drag(find.byType(Scrollable).first, Offset(0, delta));
    await tester.pumpAndSettle();
  }
}

void main() {
  group('SupportScreen', () {
    testWidgets('renders with correct title', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('shows search FAQs field', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Search FAQs...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows FREQUENTLY ASKED QUESTIONS section header',
        (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      expect(find.text('FREQUENTLY ASKED QUESTIONS'), findsOneWidget);
    });

    testWidgets('displays FAQ questions', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      expect(find.text('How do I add a gift card?'), findsOneWidget);
      expect(find.text('How do I check my card balance?'), findsOneWidget);
      expect(find.text('Is my card data secure?'), findsOneWidget);
    });

    testWidgets('FAQ expands to show answer on tap', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('How do I add a gift card?'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Tap the + button on the Cards tab'),
        findsOneWidget,
      );
    });

    testWidgets('search filters FAQ results', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'AES-256');
      await tester.pumpAndSettle();

      expect(find.text('Is my card data secure?'), findsOneWidget);
      expect(find.text('How do I add a gift card?'), findsNothing);
    });

    testWidgets('search shows no results message for unmatched query',
        (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField).first, 'xyznonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No matching questions found'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('search clear button clears query', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'balance');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('How do I add a gift card?'), findsOneWidget);
      expect(find.text('Is my card data secure?'), findsOneWidget);
    });

    testWidgets('shows CONTACT US section after scrolling', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      final contactFinder = find.text('CONTACT US');
      await scrollUntilVisible(tester, contactFinder);

      expect(contactFinder, findsOneWidget);
    });

    testWidgets('shows Email Support after scrolling', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      final emailFinder = find.text('Email Support');
      await scrollUntilVisible(tester, emailFinder);

      expect(emailFinder, findsOneWidget);
      expect(find.text('support@vaulted.app'), findsOneWidget);
    });

    testWidgets('shows Send Email button after scrolling', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      final sendFinder = find.text('Send Email');
      await scrollUntilVisible(tester, sendFinder);

      expect(sendFinder, findsOneWidget);
    });

    testWidgets('shows Send Feedback button after scrolling', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      final feedbackFinder = find.text('Send Feedback');
      await scrollUntilVisible(tester, feedbackFinder);

      expect(feedbackFinder, findsOneWidget);
    });

    testWidgets('Send Feedback opens bottom sheet', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      final feedbackFinder = find.text('Send Feedback');
      await scrollUntilVisible(tester, feedbackFinder);

      await tester.tap(feedbackFinder);
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Tell us what you think, report a bug, or suggest a feature.'),
        findsOneWidget,
      );
      expect(find.text('Your feedback...'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('feedback bottom sheet Cancel closes it', (tester) async {
      await tester.pumpWidget(buildTestApp(const SupportScreen()));
      await tester.pumpAndSettle();

      final feedbackFinder = find.text('Send Feedback');
      await scrollUntilVisible(tester, feedbackFinder);

      await tester.tap(feedbackFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Your feedback...'), findsNothing);
    });
  });
}
