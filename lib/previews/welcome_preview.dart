import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../core/theme/vaulted_theme.dart';
import '../presentation/screens/auth/welcome_screen.dart';

@Preview(name: 'Welcome Screen')
Widget welcomeScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: VaultedTheme.dark(),
    home: const WelcomeScreen(),
  );
}
