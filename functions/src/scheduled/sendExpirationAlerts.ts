import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { db, messaging } from "../utils/admin";

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

    // Query all users, then their cards
    const usersSnap = await db.collection("users").get();
    let alertCount = 0;

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

        // Create in-app notification
        await db.collection(`users/${uid}/notifications`).add({
          type: "expiration_alert",
          title: "Card Expiring Soon",
          body: `Your ${card.retailerName} card ($${card.balance}) expires in ${daysLeft} day${daysLeft === 1 ? "" : "s"}.`,
          cardId: cardDoc.id,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        alertCount++;
      }

      // Send FCM push if user has a token
      if (userData.fcmToken) {
        try {
          await messaging.send({
            token: userData.fcmToken,
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

    functions.logger.info("Expiration alerts sent", { alertCount });
  });
