import * as functions from "firebase-functions";
import { db } from "../utils/admin";

/**
 * User callable: export the caller's own data as JSON.
 *
 * Gathers: profile, cards, transactions, notifications.
 * Returns a single JSON payload for GDPR / data-portability compliance.
 */
export const exportUserData = functions.https.onCall(async (_data, context) => {
  // ── Auth gate ──────────────────────────────────────────────────
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required."
    );
  }

  const uid = context.auth.uid;

  // ── Gather profile ─────────────────────────────────────────────
  const userSnap = await db.doc(`users/${uid}`).get();
  if (!userSnap.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "User profile not found."
    );
  }
  const profile = userSnap.data();

  // ── Gather cards (strip encrypted secrets) ─────────────────────
  const cardsSnap = await db.collection(`users/${uid}/cards`).get();
  const cards = cardsSnap.docs.map((doc) => {
    const data = doc.data();
    // Strip encrypted sensitive fields from export for security
    const { cardNumberEncrypted, pinEncrypted, ...safeData } = data;
    return {
      id: doc.id,
      ...safeData,
      cardNumberPresent: !!cardNumberEncrypted,
      pinPresent: !!pinEncrypted,
    };
  });

  // ── Gather transactions ────────────────────────────────────────
  const txSnap = await db
    .collection(`users/${uid}/transactions`)
    .orderBy("createdAt", "desc")
    .get();
  const transactions = txSnap.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  // ── Gather notifications ───────────────────────────────────────
  const notifSnap = await db
    .collection(`users/${uid}/notifications`)
    .orderBy("createdAt", "desc")
    .get();
  const notifications = notifSnap.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  functions.logger.info("User data exported", {
    uid,
    cards: cards.length,
    transactions: transactions.length,
    notifications: notifications.length,
  });

  return {
    exportedAt: new Date().toISOString(),
    profile,
    cards,
    transactions,
    notifications,
  };
});
