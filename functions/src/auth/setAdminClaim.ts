import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { auth, db, isAdmin, writeAuditLog } from "../utils/admin";

interface SetAdminData {
  targetUid?: string;
}

/**
 * Callable function (admin-only): set the admin custom claim on a target user
 * and update their Firestore role to "admin".
 */
export const setAdminClaim = functions.https.onCall(
  async (data: SetAdminData, context) => {
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
        "Only admins can grant admin privileges."
      );
    }

    const rawTargetUid = data?.targetUid;
    if (!rawTargetUid || typeof rawTargetUid !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "targetUid must be a non-empty string."
      );
    }

    const targetUid = rawTargetUid.trim();
    if (targetUid.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "targetUid must be a non-empty string."
      );
    }

    const targetUser = await auth.getUser(targetUid);
    await auth.setCustomUserClaims(targetUid, {
      ...(targetUser.customClaims ?? {}),
      admin: true,
    });

    await db.doc(`users/${targetUid}`).set({ role: "admin" }, { merge: true });
    await db.doc("admin/config").set(
      {
        adminUids: admin.firestore.FieldValue.arrayUnion([targetUid]),
      },
      { merge: true }
    );

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
