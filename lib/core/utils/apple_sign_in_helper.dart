import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Whether Apple Sign-In is available on the current platform.
///
/// Returns `true` on iOS, macOS, and web. Returns `false` on Android
/// and other platforms where Apple Sign-In is not natively supported.
bool get isAppleSignInAvailable {
  if (kIsWeb) return true;
  return Platform.isIOS || Platform.isMacOS;
}

/// Signs in with Apple across web and mobile platforms.
///
/// On web, uses Firebase Auth popup flow directly.
/// On iOS/macOS, uses the `sign_in_with_apple` package to obtain
/// credentials and then signs in via Firebase Auth.
///
/// Returns the [UserCredential] on success, or `null` if the user
/// cancelled the flow.
Future<UserCredential?> signInWithApple() async {
  final auth = FirebaseAuth.instance;

  if (kIsWeb) {
    final provider = OAuthProvider('apple.com');
    provider.addScope('email');
    provider.addScope('name');
    return auth.signInWithPopup(provider);
  }

  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  );

  final oauthCredential = OAuthProvider('apple.com').credential(
    idToken: appleCredential.identityToken,
    accessToken: appleCredential.authorizationCode,
  );

  final userCredential = await auth.signInWithCredential(oauthCredential);

  // Apple only provides the display name on the first sign-in.
  // Persist it to the Firebase user profile if available.
  final displayName = [
    appleCredential.givenName,
    appleCredential.familyName,
  ].where((n) => n != null && n.isNotEmpty).join(' ');

  if (displayName.isNotEmpty &&
      (userCredential.user?.displayName == null ||
          userCredential.user!.displayName!.isEmpty)) {
    await userCredential.user?.updateDisplayName(displayName);
  }

  return userCredential;
}
