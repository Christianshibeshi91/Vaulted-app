import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';

/// Stream of Firebase auth state changes (login / logout).
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Fetches the full [UserModel] document from Firestore for the current user.
///
/// Returns `null` when not authenticated or when the document doesn't exist.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        // Firestore doc missing — build from Firebase Auth data
        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          avatarUrl: user.photoURL,
        );
      }

      // Check if user is suspended — force sign out
      if (doc.data()?['isSuspended'] == true) {
        await FirebaseAuth.instance.signOut();
        return null;
      }

      return UserModel.fromJson({
        'uid': user.uid,
        ...doc.data()!,
      });
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

/// Whether the current user has the `admin` role (via Firebase custom claims).
final isAdminProvider = FutureProvider<bool>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return false;
  final idTokenResult = await user.getIdTokenResult();
  return idTokenResult.claims?['admin'] == true;
});

/// Manual override for onboarding completion (synchronous, no Firestore delay).
final isOnboardedOverrideProvider = StateProvider<bool?>((ref) => null);

/// Whether the current user has completed onboarding.
/// The override takes precedence so navigation is instant after skip/complete.
final isOnboardedProvider = Provider<bool>((ref) {
  final override = ref.watch(isOnboardedOverrideProvider);
  if (override != null) return override;

  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.onboardingComplete ?? false;
});
