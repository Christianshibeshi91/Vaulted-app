import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Signs in with Google across web and mobile platforms.
///
/// On web, uses Firebase Auth popup flow directly.
/// On mobile, uses the `google_sign_in` package to obtain credentials
/// and then signs in via Firebase Auth.
///
/// Returns the [UserCredential] on success, or `null` if the user
/// cancelled the flow.
Future<UserCredential?> signInWithGoogle() async {
  final auth = FirebaseAuth.instance;

  if (kIsWeb) {
    // Web: use popup-based sign-in
    final provider = GoogleAuthProvider();
    provider.addScope('email');
    provider.addScope('profile');
    return auth.signInWithPopup(provider);
  }

  // Mobile: use google_sign_in package
  final googleSignIn = GoogleSignIn();
  final account = await googleSignIn.signIn();
  if (account == null) return null; // user cancelled

  final googleAuth = await account.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  return auth.signInWithCredential(credential);
}
