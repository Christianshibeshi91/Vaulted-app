import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../core/theme/vaulted_theme.dart';
import '../presentation/screens/onboarding/onboarding_welcome_screen.dart';
import '../presentation/screens/onboarding/onboarding_profile_screen.dart';

@Preview(name: 'Onboarding Welcome')
Widget onboardingWelcomePreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: VaultedTheme.dark(),
    home: const OnboardingWelcomeScreen(),
  );
}

@Preview(name: 'Onboarding Profile')
Widget onboardingProfilePreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: VaultedTheme.dark(),
    home: const OnboardingProfileScreen(),
  );
}
