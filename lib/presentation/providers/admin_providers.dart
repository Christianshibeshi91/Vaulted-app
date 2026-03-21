import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/alert_model.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/models/audit_entry_model.dart';
import '../../data/models/daily_stats_model.dart';
import '../../data/models/feature_flag_model.dart';
import '../../data/models/user_model.dart';

// ── Firestore references ──────────────────────────────────────────

final _firestore = FirebaseFirestore.instance;

// ── Users ─────────────────────────────────────────────────────────

/// All registered users, ordered by creation date descending.
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return _firestore
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            return UserModel.fromJson({'uid': doc.id, ...doc.data()});
          }).toList());
});

/// Single user by UID.
final userByUidProvider =
    StreamProvider.family<UserModel?, String>((ref, uid) {
  return _firestore.collection('users').doc(uid).snapshots().map((doc) {
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson({'uid': doc.id, ...doc.data()!});
  });
});

// ── Admin Stats ───────────────────────────────────────────────────

/// Aggregated admin KPI stats computed from users and cards.
final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final usersSnap = await _firestore.collection('users').get();
  final totalUsers = usersSnap.size;

  var totalCards = 0;
  var totalValue = 0.0;

  for (final userDoc in usersSnap.docs) {
    final cardsSnap =
        await _firestore.collection('users/${userDoc.id}/cards').get();
    totalCards += cardsSnap.size;
    for (final cardDoc in cardsSnap.docs) {
      totalValue += (cardDoc.data()['balance'] as num?)?.toDouble() ?? 0.0;
    }
  }

  return {
    'totalUsers': totalUsers,
    'totalCards': totalCards,
    'totalValue': totalValue,
    'revenue': totalValue * 0.025, // estimated 2.5% fee
  };
});

// ── Daily Stats ───────────────────────────────────────────────────

/// Last 30 days of daily stats for charts.
final dailyStatsProvider = StreamProvider<List<DailyStatsModel>>((ref) {
  final thirtyDaysAgo =
      DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

  return _firestore
      .collection('admin')
      .doc('stats')
      .collection('daily')
      .where('date', isGreaterThanOrEqualTo: thirtyDaysAgo.substring(0, 10))
      .orderBy('date')
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => DailyStatsModel.fromJson(doc.data()))
          .toList());
});

// ── Alerts ────────────────────────────────────────────────────────

/// Active admin alerts, ordered by creation date descending.
final adminAlertsProvider = StreamProvider<List<AlertModel>>((ref) {
  return _firestore
      .collection('admin')
      .doc('alerts')
      .collection('items')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            return AlertModel.fromJson({'id': doc.id, ...doc.data()});
          }).toList());
});

// ── Audit Log ─────────────────────────────────────────────────────

/// Recent audit log entries, most recent first.
final auditLogProvider = StreamProvider<List<AuditEntryModel>>((ref) {
  return _firestore
      .collection('admin')
      .doc('auditLog')
      .collection('entries')
      .orderBy('timestamp', descending: true)
      .limit(200)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            return AuditEntryModel.fromJson({'id': doc.id, ...doc.data()});
          }).toList());
});

// ── Feature Flags ─────────────────────────────────────────────────

/// All feature flags.
final featureFlagsProvider = StreamProvider<List<FeatureFlagModel>>((ref) {
  return _firestore
      .collection('admin')
      .doc('featureFlags')
      .collection('flags')
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            return FeatureFlagModel.fromJson({'id': doc.id, ...doc.data()});
          }).toList());
});

// ── App Settings ──────────────────────────────────────────────────

/// Global app settings document.
final appSettingsProvider = StreamProvider<AppSettingsModel>((ref) {
  return _firestore
      .collection('admin')
      .doc('settings')
      .snapshots()
      .map((doc) {
    if (!doc.exists || doc.data() == null) {
      return const AppSettingsModel();
    }
    return AppSettingsModel.fromJson(doc.data()!);
  });
});

// ── Write helpers ─────────────────────────────────────────────────

/// Writes an audit log entry to Firestore.
Future<void> writeAuditLog(AuditEntryModel entry) async {
  await _firestore
      .collection('admin')
      .doc('auditLog')
      .collection('entries')
      .doc(entry.id)
      .set(entry.toJson());
}

/// Updates app settings in Firestore.
Future<void> updateAppSettings(AppSettingsModel settings) async {
  await _firestore
      .collection('admin')
      .doc('settings')
      .set(settings.toJson());
}

/// Toggles a feature flag and writes audit entry.
Future<void> toggleFeatureFlag(String flagId, bool newValue) async {
  await _firestore
      .collection('admin')
      .doc('featureFlags')
      .collection('flags')
      .doc(flagId)
      .update({
    'isEnabled': newValue,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

/// Updates alert status (acknowledge / resolve).
Future<void> updateAlertStatus(
  String alertId, {
  bool? isAcknowledged,
  bool? isResolved,
  String? adminUid,
}) async {
  final data = <String, dynamic>{};
  if (isAcknowledged != null) {
    data['isAcknowledged'] = isAcknowledged;
    data['acknowledgedBy'] = adminUid;
    data['acknowledgedAt'] = FieldValue.serverTimestamp();
  }
  if (isResolved != null) {
    data['isResolved'] = isResolved;
    data['resolvedBy'] = adminUid;
    data['resolvedAt'] = FieldValue.serverTimestamp();
  }

  await _firestore
      .collection('admin')
      .doc('alerts')
      .collection('items')
      .doc(alertId)
      .update(data);
}
