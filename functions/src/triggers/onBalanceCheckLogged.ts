import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";

/**
 * Aggregates balance check analytics when a new event is logged.
 *
 * Updates daily and per-retailer counters in the analytics collection.
 * This data feeds reporting dashboards and partnership pitch decks.
 */
export const onBalanceCheckLogged = onDocumentCreated(
  "analytics/balance_checks/events/{eventId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const db = getFirestore();
    const retailerId = data.retailerId as string;
    const success = data.success as boolean;
    const method = (data.method as string) || "unknown";

    // Today's date key for daily aggregation
    const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD

    // Update daily stats
    const dailyRef = db
      .collection("analytics")
      .doc("balance_checks")
      .collection("daily")
      .doc(today);

    try {
      await dailyRef.set(
        {
          totalChecks: FieldValue.increment(1),
          successCount: FieldValue.increment(success ? 1 : 0),
          failureCount: FieldValue.increment(success ? 0 : 1),
          [`methods.${method}`]: FieldValue.increment(1),
          [`retailers.${retailerId}`]: FieldValue.increment(1),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    } catch (error) {
      logger.error("Failed to update daily analytics:", error);
    }

    // Update per-retailer lifetime stats
    const retailerRef = db
      .collection("analytics")
      .doc("balance_checks")
      .collection("retailers")
      .doc(retailerId);

    try {
      await retailerRef.set(
        {
          totalChecks: FieldValue.increment(1),
          successCount: FieldValue.increment(success ? 1 : 0),
          lastCheckedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    } catch (error) {
      logger.error(
        `Failed to update retailer analytics for ${retailerId}:`,
        error
      );
    }
  }
);
