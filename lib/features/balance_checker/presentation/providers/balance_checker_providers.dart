import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/retailer_config_model.dart';
import '../../data/retailer_configs.dart';
import '../../domain/entities/retailer_config.dart';

// ── Retailer config providers ────────────────────────────────────

/// Provides all retailer configs, preferring Firestore overrides.
///
/// Falls back to the hard-coded [RetailerConfigs.all] if Firestore
/// fetch fails or configs haven't been synced yet.
final retailerConfigsProvider =
    FutureProvider<List<RetailerConfig>>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('retailer_configs')
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs
          .map((doc) => RetailerConfigModel.fromFirestore(doc))
          .toList();
    }
  } catch (_) {
    // Fall back to hard-coded configs
  }
  return RetailerConfigs.all;
});

/// Look up a single retailer config by ID.
final retailerConfigByIdProvider =
    Provider.family<RetailerConfig?, String>((ref, id) {
  final configs = ref.watch(retailerConfigsProvider).valueOrNull;
  if (configs == null) return RetailerConfigs.byId(id);
  try {
    return configs.firstWhere((c) => c.id == id);
  } catch (_) {
    return RetailerConfigs.byId(id);
  }
});

// ── Rate limiting ────────────────────────────────────────────────

/// Tracks the last balance check timestamp per retailer ID.
///
/// Enforces: max 1 check per retailer per 5 minutes (client-side).
final _lastCheckTimestamps =
    StateProvider<Map<String, DateTime>>((ref) => {});

/// Whether a balance check is allowed for the given retailer.
///
/// Returns `true` if no check has been done in the last 5 minutes.
final canCheckBalanceProvider =
    Provider.family<bool, String>((ref, retailerId) {
  final timestamps = ref.watch(_lastCheckTimestamps);
  final lastCheck = timestamps[retailerId];
  if (lastCheck == null) return true;
  return DateTime.now().difference(lastCheck).inMinutes >= 5;
});

/// Records that a balance check was performed for [retailerId].
void recordBalanceCheck(WidgetRef ref, String retailerId) {
  ref.read(_lastCheckTimestamps.notifier).update((state) {
    return {...state, retailerId: DateTime.now()};
  });
}

// ── Balance check state ──────────────────────────────────────────

/// Current state of the balance check flow.
enum BalanceCheckStatus {
  idle,
  loading,
  captchaRequired,
  success,
  error,
}

/// Holds the state of the current balance check operation.
class BalanceCheckState {
  const BalanceCheckState({
    this.status = BalanceCheckStatus.idle,
    this.balance,
    this.errorMessage,
  });

  final BalanceCheckStatus status;
  final double? balance;
  final String? errorMessage;

  BalanceCheckState copyWith({
    BalanceCheckStatus? status,
    double? balance,
    String? errorMessage,
  }) {
    return BalanceCheckState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final balanceCheckStateProvider =
    StateProvider<BalanceCheckState>((ref) => const BalanceCheckState());

// ── Analytics ────────────────────────────────────────────────────

/// Logs a balance check result to Firestore analytics.
Future<void> logBalanceCheckAnalytics({
  required String retailerId,
  required bool success,
  required String method,
  required int durationMs,
  required bool captchaRequired,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  try {
    await FirebaseFirestore.instance
        .collection('analytics')
        .doc('balance_checks')
        .collection('events')
        .add({
      'retailerId': retailerId,
      'userId': uid,
      'success': success,
      'method': method,
      'durationMs': durationMs,
      'captchaRequired': captchaRequired,
      'checkedAt': FieldValue.serverTimestamp(),
    });
  } catch (_) {
    // Analytics are best-effort; don't crash on failure
  }
}
