import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/theme/app_theme.dart';
import 'package:vaulted/core/theme/colors.dart';
import 'package:vaulted/presentation/widgets/common/vaulted_badge.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    theme: VaultedTheme.dark,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('VaultedBadge', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedBadge('Active'),
      ));

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('defaults to gold color', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedBadge('Gold'),
      ));

      final text = tester.widget<Text>(find.text('Gold'));
      expect(text.style?.color, VaultedColors.accentGold);
    });

    testWidgets('renders success badge with correct foreground', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedBadge('OK', color: VaultedBadgeColor.success),
      ));

      final text = tester.widget<Text>(find.text('OK'));
      expect(text.style?.color, VaultedColors.success);
    });

    testWidgets('renders warning badge with correct foreground', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedBadge('Warning', color: VaultedBadgeColor.warning),
      ));

      final text = tester.widget<Text>(find.text('Warning'));
      expect(text.style?.color, VaultedColors.warning);
    });

    testWidgets('renders danger badge with correct foreground', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedBadge('Error', color: VaultedBadgeColor.danger),
      ));

      final text = tester.widget<Text>(find.text('Error'));
      expect(text.style?.color, VaultedColors.danger);
    });

    testWidgets('renders info badge with correct foreground', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedBadge('Info', color: VaultedBadgeColor.info),
      ));

      final text = tester.widget<Text>(find.text('Info'));
      expect(text.style?.color, VaultedColors.info);
    });

    testWidgets('renders with small size by default', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedBadge('Small'),
      ));

      // Badge exists and renders
      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('renders with medium size', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedBadge('Medium', size: VaultedBadgeSize.medium),
      ));

      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('has a pill-shaped container with tinted background', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedBadge('Pill', color: VaultedBadgeColor.success),
      ));

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Pill'),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
      // Background should be the foreground color at 12% opacity
      expect(decoration.color, isNotNull);
    });
  });
}
