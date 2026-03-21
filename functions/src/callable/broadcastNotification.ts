import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { db, messaging, isAdmin, writeAuditLog } from "../utils/admin";

interface BroadcastData {
  title: string;
  body: string;
  type?: string;
  data?: Record<string, string>;
}

/**
 * Admin-only callable: broadcast a notification to every user.
 *
 * 1. Write to each user's /notifications subcollection.
 * 2. Send FCM push to every user with a stored FCM token.
 */
export const broadcastNotification = functions.https.onCall(
  async (data: BroadcastData, context) => {
    // ── Auth gate ────────────────────────────────────────────────
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required."
      );
    }

    const callerUid = context.auth.uid;
    if (!(await isAdmin(callerUid))) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can broadcast notifications."
      );
    }

    // ── Validate input ───────────────────────────────────────────
    if (!data.title || typeof data.title !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "title is required and must be a string."
      );
    }
    if (!data.body || typeof data.body !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "body is required and must be a string."
      );
    }

    const notificationType = data.type ?? "system_broadcast";

    // ── Write to all users ───────────────────────────────────────
    const usersSnap = await db.collection("users").get();
    const fcmTokens: string[] = [];
    let written = 0;

    let batch = db.batch();
    let batchCount = 0;

    for (const userDoc of usersSnap.docs) {
      const ref = db.collection(`users/${userDoc.id}/notifications`).doc();
      batch.set(ref, {
        type: notificationType,
        title: data.title,
        body: data.body,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      written++;
      batchCount++;

      // Collect FCM tokens
      const userData = userDoc.data();
      if (userData.fcmToken && typeof userData.fcmToken === "string") {
        fcmTokens.push(userData.fcmToken);
      }

      if (batchCount >= 450) {
        await batch.commit();
        batch = db.batch();
        batchCount = 0;
      }
    }

    if (batchCount > 0) await batch.commit();

    // ── Send FCM push ────────────────────────────────────────────
    let fcmSuccess = 0;
    let fcmFailed = 0;

    if (fcmTokens.length > 0) {
      // FCM multicast supports up to 500 tokens per call
      const chunks: string[][] = [];
      for (let i = 0; i < fcmTokens.length; i += 500) {
        chunks.push(fcmTokens.slice(i, i + 500));
      }

      for (const chunk of chunks) {
        try {
          const result = await messaging.sendEachForMulticast({
            tokens: chunk,
            notification: {
              title: data.title,
              body: data.body,
            },
            data: data.data ?? {},
          });
          fcmSuccess += result.successCount;
          fcmFailed += result.failureCount;
        } catch (err) {
          functions.logger.error("FCM multicast failed", { error: err });
          fcmFailed += chunk.length;
        }
      }
    }

    // ── Audit log ────────────────────────────────────────────────
    await writeAuditLog({
      action: "BROADCAST_NOTIFICATION",
      performedBy: callerUid,
      details: {
        title: data.title,
        recipientCount: written,
        fcmSuccess,
        fcmFailed,
      },
    });

    functions.logger.info("Broadcast sent", {
      written,
      fcmSuccess,
      fcmFailed,
    });

    return { success: true, written, fcmSuccess, fcmFailed };
  }
);
