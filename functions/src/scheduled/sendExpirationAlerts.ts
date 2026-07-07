import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { FirebaseFirestore } from "@google-cloud/firestore";
import { db, getPushToken, messaging } from "../utils/admin";

/**
 * Scheduled function: runs daily at 09:00 UTC.
 * Queries gift cards expiring within 30 days and sends push notifications.
 */
export const sendExpirationAlerts = functions.pubsub
  .schedule("0 9 * * *")
  .timeZone("UTC")
  .onRun(async () => {
    const now = new Date();
    const thirtyDaysFromNow = new Date(
      now.getTime() + 30 * 24 * 60 * 60 * 1000
    );

    // Query users in batches to avoid OOM on large user bases
    let alertCount = 0;
    let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;
    const batchSize = 500;

    while (true) {
    let query: FirebaseFirestore.Query = db.collection("users").orderBy("__name__").limit(batchSize);
    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }
    const usersSnap = await query.get();
    if (usersSnap.empty) break;

    for (const userDoc of usersSnap.docs) {
      const uid = userDoc.id;
      const userData = userDoc.data();

      // Skip users who opted out of expiration alerts
      if (userData.notificationPreferences?.expirationAlerts === false) {
        continue;
      }

      // Find cards expiring within 30 days
      const cardsSnap = await db
        .collection(`users/${uid}/cards`)
        .where("expirationDate", ">=", admin.firestore.Timestamp.fromDate(now))
        .where(
          "expirationDate",
          "<=",
          admin.firestore.Timestamp.fromDate(thirtyDaysFromNow)
        )
        .get();

      if (cardsSnap.empty) continue;

      for (const cardDoc of cardsSnap.docs) {
        const card = cardDoc.data();
        const expirationDate = (
          card.expirationDate as admin.firestore.Timestamp
        ).toDate();
        const daysLeft = Math.ceil(
          (expirationDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
        );

        // Dedup: skip if an expiration alert was already sent for this card in the last 7 days
        const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        const existingAlert = await db
          .collection(`users/${uid}/notifications`)
          .where("type", "==", "expiration_alert")
          .where("cardId", "==", cardDoc.id)
          .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(sevenDaysAgo))
          .limit(1)
          .get();

        if (!existingAlert.empty) continue;

        // Create in-app notification
        await db.collection(`users/${uid}/notifications`).add({
          type: "expiration_alert",
          title: "Card Expiring Soon",
          body: `Your ${card.retailer} card ($${card.balance}) expires in ${daysLeft} day${daysLeft === 1 ? "" : "s"}.`,
          cardId: cardDoc.id,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        alertCount++;
      }

      // Send FCM push if user has a token
      const pushToken = getPushToken(userData);
      if (pushToken) {
        try {
          await messaging.send({
            token: pushToken,
            notification: {
              title: "Cards Expiring Soon",
              body: `You have ${cardsSnap.size} card${cardsSnap.size === 1 ? "" : "s"} expiring within 30 days.`,
            },
            data: {
              type: "expiration_alert",
              cardCount: String(cardsSnap.size),
            },
          });
        } catch (err) {
          // Token may be stale — log but do not fail the batch
          functions.logger.warn("FCM send failed", { uid, error: err });
        }
      }
    }

    lastDoc = usersSnap.docs[usersSnap.docs.length - 1];
    if (usersSnap.size < batchSize) break;
    } // end while

    functions.logger.info("Expiration alerts sent", { alertCount });
  });
