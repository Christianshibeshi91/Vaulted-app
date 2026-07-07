import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { FirebaseFirestore } from "@google-cloud/firestore";
import { db } from "../utils/admin";

/**
 * Scheduled function: runs daily at midnight UTC.
 * Aggregates platform-wide stats and writes to /admin/stats/daily/{date}.
 */
export const calculateDailyStats = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("UTC")
  .onRun(async () => {
    const now = new Date();
    const dateKey = now.toISOString().split("T")[0]; // YYYY-MM-DD

    // Beginning of today
    const startOfDay = new Date(
      Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate())
    );
    const startTimestamp = admin.firestore.Timestamp.fromDate(startOfDay);

    let totalUsers = 0;
    let newUsers = 0;
    let premiumUsers = 0;
    let totalCards = 0;
    let totalCardValue = 0;

    // Process users in batches to avoid OOM
    let lastUserDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;
    const batchSize = 500;

    while (true) {
      let usersQuery: FirebaseFirestore.Query = db.collection("users")
        .orderBy("__name__")
        .limit(batchSize);
      if (lastUserDoc) {
        usersQuery = usersQuery.startAfter(lastUserDoc);
      }
      const usersSnap = await usersQuery.get();
      if (usersSnap.empty) break;

      for (const userDoc of usersSnap.docs) {
        totalUsers++;
        const userData = userDoc.data();

        // New users created today
        const createdAt = userData.createdAt as
          | admin.firestore.Timestamp
          | undefined;
        if (createdAt && createdAt.toMillis() >= startTimestamp.toMillis()) {
          newUsers++;
        }

        // Premium / paid plan users
        if (userData.plan && userData.plan !== "free") {
          premiumUsers++;
        }

        // Aggregate card data
        const cardsSnap = await db
          .collection(`users/${userDoc.id}/cards`)
          .get();
        totalCards += cardsSnap.size;

        for (const cardDoc of cardsSnap.docs) {
          const card = cardDoc.data();
          totalCardValue += typeof card.balance === "number" ? card.balance : 0;
        }
      }

      lastUserDoc = usersSnap.docs[usersSnap.docs.length - 1];
      if (usersSnap.size < batchSize) break;
    }

    const stats = {
      totalUsers,
      newUsers,
      premiumUsers,
      totalCards,
      totalCardValue: Math.round(totalCardValue * 100) / 100,
      calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.doc(`admin/stats/daily/${dateKey}`).set(stats);

    functions.logger.info("Daily stats calculated", {
      dateKey,
      ...stats,
    });
  });
