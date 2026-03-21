import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/theme/app_theme.dart';
import 'package:vaulted/presentation/widgets/common/vaulted_input.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    theme: VaultedTheme.dark,
    home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
  );
}

void main() {
  group('VaultedInput', () {
    testWidgets('renders with label text', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedInput(label: 'Email'),
      ));

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders with hint text', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedInput(hint: 'Enter your email'),
      ));

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('renders both label and hint', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedInput(label: 'Password', hint: 'Min 8 characters'),
      ));

      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Min 8 characters'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildTestApp(
        VaultedInput(controller: controller, label: 'Name'),
      ));

      await tester.enterText(find.byType(TextFormField), 'John Doe');
      expect(controller.text, 'John Doe');
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedInput(label: 'Password', obscureText: true),
      ));

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.obscureText, isTrue);
    });

    testWidgets('shows suffix icon when provided', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedInput(
          label: 'Password',
          suffixIcon: Icon(Icons.visibility),
        ),
      ));

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows prefix icon when provided', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedInput(
          label: 'Search',
          prefixIcon: Icon(Icons.search),
        ),
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;
      await tester.pumpWidget(buildTestApp(
        VaultedInput(
          label: 'Input',
          onChanged: (value) => changedValue = value,
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'hello');
      expect(changedValue, 'hello');
    });

    testWidgets('shows validation error when validator fails', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(buildTestApp(
        Form(
          key: formKey,
          child: VaultedInput(
            label: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              return null;
            },
          ),
        ),
      ));

      // Trigger validation
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('does not show error when validation passes', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: 'valid@email.com');
      await tester.pumpWidget(buildTestApp(
        Form(
          key: formKey,
          child: VaultedInput(
            label: 'Email',
            controller: controller,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              return null;
            },
          ),
        ),
      ));

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Required'), findsNothing);
    });

    testWidgets('disables input when enabled is false', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedInput(label: 'Disabled', enabled: false),
      ));

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });

    testWidgets('contains a TextFormField', (tester) async {
      await tester.pumpWidget(buildTestApp(
        const VaultedInput(label: 'Test'),
      ));

      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
