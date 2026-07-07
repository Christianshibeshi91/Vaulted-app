import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { db, getPushToken, messaging, isAdmin, writeAuditLog } from "../utils/admin";

interface BroadcastData {
  title?: string;
  body?: string;
  type?: string;
  data?: Record<string, string>;
}

const MAX_TITLE_LENGTH = 120;
const MAX_BODY_LENGTH = 500;
const MAX_DATA_ENTRIES = 20;
const MAX_DATA_VALUE_LENGTH = 256;

/**
 * Admin-only callable: broadcast a notification to every user.
 *
 * 1. Write to each user's /notifications subcollection.
 * 2. Send FCM push to every user with a stored push token.
 */
export const broadcastNotification = functions.https.onCall(
  async (data: BroadcastData, context) => {
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

    const title = data?.title?.trim();
    const body = data?.body?.trim();

    if (!title) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "title is required and must be a string."
      );
    }
    if (!body) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "body is required and must be a string."
      );
    }
    if (title.length > MAX_TITLE_LENGTH || body.length > MAX_BODY_LENGTH) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Notification title/body exceed the maximum length."
      );
    }

    const payloadData = sanitizeDataPayload(data?.data);
    const notificationType = data?.type?.trim() || "system_broadcast";

    const usersSnap = await db.collection("users").get();
    const tokenSet = new Set<string>();
    let written = 0;

    let batch = db.batch();
    let batchCount = 0;

    for (const userDoc of usersSnap.docs) {
      const ref = db.collection(`users/${userDoc.id}/notifications`).doc();
      batch.set(ref, {
        type: notificationType,
        title,
        body,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      written++;
      batchCount++;

      const pushToken = getPushToken(userDoc.data());
      if (pushToken) {
        tokenSet.add(pushToken);
      }

      if (batchCount >= 450) {
        await batch.commit();
        batch = db.batch();
        batchCount = 0;
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    const tokens = Array.from(tokenSet);
    let fcmSuccess = 0;
    let fcmFailed = 0;

    for (let i = 0; i < tokens.length; i += 500) {
      const chunk = tokens.slice(i, i + 500);
      try {
        const result = await messaging.sendEachForMulticast({
          tokens: chunk,
          notification: { title, body },
          data: payloadData,
        });
        fcmSuccess += result.successCount;
        fcmFailed += result.failureCount;
      } catch (err) {
        functions.logger.error("FCM multicast failed", { error: err });
        fcmFailed += chunk.length;
      }
    }

    await writeAuditLog({
      action: "BROADCAST_NOTIFICATION",
      performedBy: callerUid,
      details: {
        title,
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

function sanitizeDataPayload(
  payload: Record<string, string> | undefined
): Record<string, string> {
  if (payload == null) return {};
  if (typeof payload !== "object" || Array.isArray(payload)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "data must be an object of string key-value pairs."
    );
  }

  const entries = Object.entries(payload);
  if (entries.length > MAX_DATA_ENTRIES) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "data contains too many entries."
    );
  }

  const sanitized: Record<string, string> = {};
  for (const [key, value] of entries) {
    if (typeof key !== "string" || key.trim().length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "data keys must be non-empty strings."
      );
    }
    if (typeof value !== "string" || value.length > MAX_DATA_VALUE_LENGTH) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "data values must be strings within the allowed length."
      );
    }
    sanitized[key.trim()] = value;
  }

  return sanitized;
}
