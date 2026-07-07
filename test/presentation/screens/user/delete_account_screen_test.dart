import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/theme/app_theme.dart';
import 'package:vaulted/presentation/screens/user/delete_account_screen.dart';

Widget buildTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: VaultedTheme.dark,
      home: child,
    ),
  );
}

void main() {
  group('DeleteAccountScreen', () {
    // Use a tall viewport so the ListView renders all children
    // without needing to scroll (avoids flutter_animate + lazy build issues).
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.window.physicalSizeTestValue = const Size(1080, 4000);
      binding.window.devicePixelRatioTestValue = 1.0;
    });

    tearDown(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets('renders with correct title', (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('shows permanent action warning', (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text('This action is permanent'), findsOneWidget);
      expect(
        find.textContaining('permanently remove all of your data'),
        findsOneWidget,
      );
    });

    testWidgets('shows warning icon', (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('lists items that will be deleted', (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text('What will be deleted'), findsOneWidget);
      expect(
        find.text('All gift cards and their encrypted data'),
        findsOneWidget,
      );
      expect(find.text('Complete transaction history'), findsOneWidget);
      expect(
        find.text('Your profile and personal information'),
        findsOneWidget,
      );
    });

    testWidgets('shows deletion-related icons', (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.credit_card_outlined), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('shows Export Data First button', (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Export Data First'), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
    });

    testWidgets('shows confirmation instruction', (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Type DELETE to confirm'), findsOneWidget);
    });

    testWidgets('has a text field for DELETE confirmation', (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('delete button is disabled by default', (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Permanently Delete My Account'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('delete button enables when DELETE is typed', (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Permanently Delete My Account'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('delete button stays disabled for lowercase delete',
        (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'delete');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Permanently Delete My Account'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('reverts to disabled when text is cleared after DELETE',
        (tester) async {
      await tester.pumpWidget(buildTestApp(const DeleteAccountScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Permanently Delete My Account'),
      );
      expect(button.onPressed, isNull);
    });
  });
}
