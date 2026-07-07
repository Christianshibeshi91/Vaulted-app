import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_model.dart';

/// Real-time stream of all notifications for the current user.
final notificationsStreamProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            return NotificationModel.fromJson({'id': doc.id, ...doc.data()});
          }).toList());
});

/// Count of unread notifications derived from the stream.
///
/// Returns 0 when loading, errored, or when there are no unread items.
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsStreamProvider);
  return notifications.when(
    data: (list) => list.where((n) => !n.read).length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});

/// Marks a single notification as read.
Future<void> markNotificationRead(String notificationId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .doc(notificationId)
      .update({'read': true});
}

/// Marks all notifications as read for the current user.
///
/// Processes in batches of 450 to stay under Firestore's 500-write limit.
Future<void> markAllNotificationsRead() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final collRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .where('read', isEqualTo: false);

  QuerySnapshot unread;
  do {
    unread = await collRef.limit(450).get();
    if (unread.docs.isEmpty) break;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  } while (unread.docs.length == 450);
}

/// Deletes a single notification.
Future<void> deleteNotification(String notificationId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .doc(notificationId)
      .delete();
}
