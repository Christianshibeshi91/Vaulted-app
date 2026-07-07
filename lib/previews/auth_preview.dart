import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../core/theme/vaulted_theme.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';

@Preview(name: 'Login Screen')
Widget loginScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: VaultedTheme.dark(),
    home: const LoginScreen(),
  );
}

@Preview(name: 'Register Screen')
Widget registerScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: VaultedTheme.dark(),
    home: const RegisterScreen(),
  );
}
