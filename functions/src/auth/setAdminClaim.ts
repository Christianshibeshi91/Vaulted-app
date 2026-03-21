import * as functions from "firebase-functions";
import { auth, db, isAdmin, writeAuditLog } from "../utils/admin";

interface SetAdminData {
  targetUid: string;
}

/**
 * Callable function (admin-only): set the admin custom claim on a target user
 * and update their Firestore role to "admin".
 */
export const setAdminClaim = functions.https.onCall(
  async (data: SetAdminData, context) => {
    // ── Auth gate ──────────────────────────────────────────────
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required."
      );
    }

    const callerUid = context.auth.uid;
    const callerIsAdmin = await isAdmin(callerUid);
    if (!callerIsAdmin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can grant admin privileges."
      );
    }

    // ── Input validation ───────────────────────────────────────
    const { targetUid } = data;
    if (!targetUid || typeof targetUid !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "targetUid must be a non-empty string."
      );
    }

    // ── Set custom claim ───────────────────────────────────────
    await auth.setCustomUserClaims(targetUid, { admin: true });

    // ── Update Firestore ───────────────────────────────────────
    await db.doc(`users/${targetUid}`).update({ role: "admin" });

    // ── Audit log ──────────────────────────────────────────────
    await writeAuditLog({
      action: "SET_ADMIN_CLAIM",
      performedBy: callerUid,
      targetUid,
      details: { grantedAdmin: true },
    });

    functions.logger.info("Admin claim set", {
      callerUid,
      targetUid,
    });

    return { success: true };
  }
);
