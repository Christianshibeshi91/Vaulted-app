import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { db, messaging, getAdminUsers, getPushToken } from "../utils/admin";

/**
 * Firestore trigger: fires when any transaction document is updated
 * and the status field changes to "flagged".
 *
 * 1. Creates an admin alert in /admin/alerts/items.
 * 2. Sends FCM push to all admin users.
 */
export const onTransactionFlagged = functions.firestore
  .document("users/{userId}/transactions/{transactionId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only fire when status transitions TO "flagged"
    if (before.status === "flagged" || after.status !== "flagged") {
      return;
    }

    const { userId, transactionId } = context.params;

    // ── Create admin alert (details stored server-side only) ─────
    const alertDoc = await db.collection("admin/alerts/items").add({
      type: "fraud",
      severity: "high",
      title: "Transaction Flagged",
      message: `Transaction ${transactionId} for user ${userId} was flagged. Amount: $${after.amount}, Retailer: ${after.retailer ?? "unknown"}.`,
      isResolved: false,
      userId,
      transactionId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // ── Notify admin users via FCM ───────────────────────────────
    const adminUids = await getAdminUsers();

    for (const adminUid of adminUids) {
      const adminDoc = await db.doc(`users/${adminUid}`).get();
      const adminData = adminDoc.data();

      const pushToken = getPushToken(adminData);
      if (pushToken) {
        try {
          // Use minimal data in push — no user IDs or amounts to prevent leakage
          await messaging.send({
            token: pushToken,
            notification: {
              title: "Transaction Alert",
              body: "A transaction has been flagged for review.",
            },
            data: {
              type: "flagged_transaction",
              alertId: alertDoc.id,
            },
          });
        } catch (err) {
          functions.logger.warn("FCM to admin failed", {
            adminUid,
            error: err,
          });
        }
      }
    }

    functions.logger.info("Transaction flagged alert created", {
      userId,
      transactionId,
      amount: after.amount,
    });
  });
