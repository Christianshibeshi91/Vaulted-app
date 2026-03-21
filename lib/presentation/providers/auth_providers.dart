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

      if (!doc.exists || doc.data() == null) return null;

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

/// Whether the current user has completed onboarding.
final isOnboardedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.onboardingComplete ?? false;
});
