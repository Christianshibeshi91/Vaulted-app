import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";

/**
 * Daily health check for retailer balance-check configs.
 *
 * Verifies that each active Phase 1 retailer's balance check URL is
 * reachable (HTTP 200). If not, marks the config as "degraded".
 *
 * Runs daily at 06:00 UTC.
 */
export const configHealthCheck = onSchedule(
  { schedule: "0 6 * * *", timeZone: "UTC" },
  async () => {
    const db = getFirestore();
    const snapshot = await db
      .collection("retailer_configs")
      .where("phase", "==", "webview")
      .where("status", "in", ["active", "degraded"])
      .get();

    if (snapshot.empty) {
      logger.info("No active webview retailer configs to check.");
      return;
    }

    const results: { id: string; ok: boolean; status: number }[] = [];

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const url = data.balanceCheckUrl as string;

      if (!url) {
        results.push({ id: doc.id, ok: false, status: 0 });
        continue;
      }

      try {
        const response = await fetch(url, {
          method: "HEAD",
          signal: AbortSignal.timeout(10000),
          headers: {
            "User-Agent":
              "Mozilla/5.0 (compatible; VaultedHealthCheck/1.0)",
          },
        });

        const ok = response.status >= 200 && response.status < 400;
        results.push({ id: doc.id, ok, status: response.status });

        await doc.ref.update({
          status: ok ? "active" : "degraded",
          lastVerified: FieldValue.serverTimestamp(),
        });
      } catch (error) {
        logger.warn(`Health check failed for ${doc.id}:`, error);
        results.push({ id: doc.id, ok: false, status: 0 });

        await doc.ref.update({
          status: "degraded",
          lastVerified: FieldValue.serverTimestamp(),
        });
      }
    }

    const degraded = results.filter((r) => !r.ok);
    if (degraded.length > 0) {
      logger.warn(
        `${degraded.length} retailer(s) degraded:`,
        degraded.map((r) => r.id)
      );
    }

    logger.info(
      `Config health check complete: ${results.length} checked, ` +
        `${degraded.length} degraded.`
    );
  }
);
