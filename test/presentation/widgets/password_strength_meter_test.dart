import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/theme/app_theme.dart';
import 'package:vaulted/core/theme/colors.dart';
import 'package:vaulted/presentation/widgets/common/password_strength_meter.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    theme: VaultedTheme.dark,
    home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
  );
}

void main() {
  group('PasswordStrengthMeter', () {
    testWidgets('renders 4 animated segments', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const PasswordStrengthMeter(strength: 0),
      ));

      expect(find.byType(AnimatedContainer), findsNWidgets(4));
    });

    testWidgets('strength 0 shows no label and all segments as bgInput', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const PasswordStrengthMeter(strength: 0),
      ));

      // No strength label text for strength 0
      expect(find.text('Weak'), findsNothing);
      expect(find.text('Fair'), findsNothing);
      expect(find.text('Good'), findsNothing);
      expect(find.text('Strong'), findsNothing);

      // All 4 segments should be the inactive color
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      for (final container in containers) {
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, VaultedColors.bgInput);
      }
    });

    testWidgets('strength 1 shows "Weak" label and danger color for first segment', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const PasswordStrengthMeter(strength: 1),
      ));

      expect(find.text('Weak'), findsOneWidget);

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      // First segment should be danger (filled)
      final firstDecoration = containers[0].decoration as BoxDecoration;
      expect(firstDecoration.color, VaultedColors.danger);

      // Remaining segments should be bgInput (unfilled)
      for (var i = 1; i < 4; i++) {
        final decoration = containers[i].decoration as BoxDecoration;
        expect(decoration.color, VaultedColors.bgInput);
      }
    });

    testWidgets('strength 2 shows "Fair" label and warning color', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const PasswordStrengthMeter(strength: 2),
      ));

      expect(find.text('Fair'), findsOneWidget);

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      // First 2 segments filled with warning
      expect((containers[0].decoration as BoxDecoration).color, VaultedColors.warning);
      expect((containers[1].decoration as BoxDecoration).color, VaultedColors.warning);
      // Last 2 unfilled
      expect((containers[2].decoration as BoxDecoration).color, VaultedColors.bgInput);
      expect((containers[3].decoration as BoxDecoration).color, VaultedColors.bgInput);
    });

    testWidgets('strength 3 shows "Good" label and accentGoldLight color', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const PasswordStrengthMeter(strength: 3),
      ));

      expect(find.text('Good'), findsOneWidget);

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      // First 3 segments filled
      for (var i = 0; i < 3; i++) {
        expect(
          (containers[i].decoration as BoxDecoration).color,
          VaultedColors.accentGoldLight,
        );
      }
      // Last segment unfilled
      expect((containers[3].decoration as BoxDecoration).color, VaultedColors.bgInput);
    });

    testWidgets('strength 4 shows "Strong" label and success color on all segments', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const PasswordStrengthMeter(strength: 4),
      ));

      expect(find.text('Strong'), findsOneWidget);

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      // All 4 segments filled with success
      for (final container in containers) {
        expect(
          (container.decoration as BoxDecoration).color,
          VaultedColors.success,
        );
      }
    });

    testWidgets('label text color matches segment color', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const PasswordStrengthMeter(strength: 1),
      ));

      final text = tester.widget<Text>(find.text('Weak'));
      expect(text.style?.color, VaultedColors.danger);
    });

    testWidgets('each segment has 4px height', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const PasswordStrengthMeter(strength: 2),
      ));

      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      for (final container in containers) {
        // Height of 4 is set via constraints on AnimatedContainer
        expect(container.constraints?.maxHeight, 4.0);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, isNotNull);
      }
    });
  });
}
