import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/theme/app_theme.dart';
import 'package:vaulted/presentation/widgets/common/vaulted_button.dart';

/// Wraps [child] in a MaterialApp with the Vaulted dark theme so that
/// widgets can find inherited theme data during tests.
Widget buildTestApp(Widget child) {
  return MaterialApp(
    theme: VaultedTheme.dark,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('VaultedButton.primary', () {
    testWidgets('renders with correct label text', (tester) async {
      await tester.pumpWidget(buildTestApp(
        VaultedButton.primary('Save', onPressed: () {}),
      ));

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('fires onPressed callback on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestApp(
        VaultedButton.primary('Tap Me', onPressed: () => tapped = true),
      ));

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(buildTestApp(
        VaultedButton.primary('Load', onPressed: () {}, isLoading: true),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Label text should not be visible during loading
      expect(find.text('Load'), findsNothing);
    });

    testWidgets('does not fire onPressed when loading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestApp(
        VaultedButton.primary(
          'Loading',
          onPressed: () => tapped = true,
          isLoading: true,
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('does not fire onPressed when null (disabled)', (tester) async {
      await tester.pumpWidget(buildTestApp(
        VaultedButton.primary('Disabled', onPressed: null),
      ));

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(buildTestApp(
        VaultedButton.primary(
          'Add Card',
          onPressed: () {},
          icon: Icons.add,
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add Card'), findsOneWidget);
    });

    testWidgets('has 52px height', (tester) async {
      await tester.pumpWidget(buildTestApp(
        VaultedButton.primary('Height Test', onPressed: () {}),
      ));

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.height, 52);
    });
  });

  group('VaultedButton.secondary', () {
    testWidgets('renders as OutlinedButton with label', (tester) async {
      await tester.pumpWidget(buildTestApp(
        VaultedButton.secondary('Cancel', onPressed: () {}),
      ));

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('fires onPressed on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestApp(
        VaultedButton.secondary('Action', onPressed: () => tapped = true),
      ));

      await tester.tap(find.text('Action'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('VaultedButton.text', () {
    testWidgets('renders as TextButton with label', (tester) async {
      await tester.pumpWidget(buildTestApp(
        VaultedButton.text('Skip', onPressed: () {}),
      ));

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('fires onPressed on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestApp(
        VaultedButton.text('Learn More', onPressed: () => tapped = true),
      ));

      await tester.tap(find.text('Learn More'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('VaultedButton.danger', () {
    testWidgets('renders as ElevatedButton with label', (tester) async {
      await tester.pumpWidget(buildTestApp(
        VaultedButton.danger('Delete', onPressed: () {}),
      ));

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(buildTestApp(
        VaultedButton.danger('Deleting', onPressed: () {}, isLoading: true),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Deleting'), findsNothing);
    });

    testWidgets('fires onPressed on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestApp(
        VaultedButton.danger('Confirm', onPressed: () => tapped = true),
      ));

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
