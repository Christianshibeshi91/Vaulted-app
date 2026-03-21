import * as functions from "firebase-functions";
import { auth, db, isAdmin, writeAuditLog } from "../utils/admin";

interface DeleteUserData {
  targetUid: string;
}

/**
 * Admin-only callable: cascade-delete a user.
 *
 * 1. Delete all subcollections (cards, transactions, notifications).
 * 2. Delete the Firestore user document.
 * 3. Delete the Firebase Auth user.
 * 4. Write an audit log entry.
 */
export const deleteUserCascade = functions.https.onCall(
  async (data: DeleteUserData, context) => {
    // ── Auth gate ────────────────────────────────────────────────
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
        "Only admins can delete users."
      );
    }

    // ── Validate input ───────────────────────────────────────────
    const { targetUid } = data;
    if (!targetUid || typeof targetUid !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "targetUid must be a non-empty string."
      );
    }

    // Prevent self-deletion
    if (targetUid === callerUid) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Admins cannot delete their own account via this function."
      );
    }

    // ── Delete subcollections ────────────────────────────────────
    const subcollections = ["cards", "transactions", "notifications"];

    for (const sub of subcollections) {
      await deleteCollection(`users/${targetUid}/${sub}`);
    }

    // ── Delete user document ─────────────────────────────────────
    await db.doc(`users/${targetUid}`).delete();

    // ── Delete Auth user ─────────────────────────────────────────
    try {
      await auth.deleteUser(targetUid);
    } catch (err: unknown) {
      // User may already be deleted from Auth
      const errorCode =
        err instanceof Error && "code" in err
          ? (err as { code: string }).code
          : "";
      if (errorCode !== "auth/user-not-found") {
        throw err;
      }
    }

    // ── Audit log ────────────────────────────────────────────────
    await writeAuditLog({
      action: "DELETE_USER_CASCADE",
      performedBy: callerUid,
      targetUid,
      details: { deletedSubcollections: subcollections },
    });

    functions.logger.info("User cascade-deleted", { callerUid, targetUid });

    return { success: true };
  }
);

// ─── Helper: delete all docs in a collection ────────────────────

async function deleteCollection(path: string, batchSize = 200): Promise<void> {
  const collRef = db.collection(path);
  let query = collRef.orderBy("__name__").limit(batchSize);

  // eslint-disable-next-line no-constant-condition
  while (true) {
    const snap = await query.get();
    if (snap.empty) break;

    const batch = db.batch();
    snap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    if (snap.size < batchSize) break;
    query = collRef
      .orderBy("__name__")
      .startAfter(snap.docs[snap.docs.length - 1])
      .limit(batchSize);
  }
}
