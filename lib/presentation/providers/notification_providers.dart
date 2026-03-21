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
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsStreamProvider);
  return notifications.valueOrNull?.where((n) => !n.read).length ?? 0;
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
Future<void> markAllNotificationsRead() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final batch = FirebaseFirestore.instance.batch();
  final unread = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .where('read', isEqualTo: false)
      .get();

  for (final doc in unread.docs) {
    batch.update(doc.reference, {'read': true});
  }

  await batch.commit();
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
