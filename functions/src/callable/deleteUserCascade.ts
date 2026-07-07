import * as functions from "firebase-functions";
import { auth, db, isAdmin, storage, writeAuditLog } from "../utils/admin";

interface DeleteUserData {
  targetUid?: string;
}

/**
 * Callable: cascade-delete a user account.
 *
 * Supports two modes:
 * - Self-deletion for non-admin users.
 * - Admin deletion for other users.
 *
 * Steps:
 * 1. Delete all supported subcollections.
 * 2. Delete any user-owned Storage objects.
 * 3. Delete the Firestore user document.
 * 4. Delete the Firebase Auth user.
 * 5. Write an audit log entry.
 */
export const deleteUserCascade = functions.https.onCall(
  async (data: DeleteUserData, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required."
      );
    }

    const callerUid = context.auth.uid;
    const rawTargetUid = data?.targetUid ?? callerUid;
    if (typeof rawTargetUid !== "string") {
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

    const callerIsAdmin = await isAdmin(callerUid);
    const isSelfDelete = targetUid === callerUid;

    if (!isSelfDelete && !callerIsAdmin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can delete other users."
      );
    }

    if (isSelfDelete && callerIsAdmin) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Admins cannot delete their own account via this function."
      );
    }

    const subcollections = ["cards", "transactions", "notifications"];
    for (const sub of subcollections) {
      await deleteCollection(`users/${targetUid}/${sub}`);
    }

    await deleteUserFiles(targetUid);
    await db.doc(`users/${targetUid}`).delete();

    try {
      await auth.deleteUser(targetUid);
    } catch (err: unknown) {
      const errorCode =
        err instanceof Error && "code" in err
          ? (err as { code: string }).code
          : "";
      if (errorCode !== "auth/user-not-found") {
        throw err;
      }
    }

    await writeAuditLog({
      action: "DELETE_USER_CASCADE",
      performedBy: callerUid,
      targetUid,
      details: {
        deletedSubcollections: subcollections,
        deletedStoragePrefixes: [`users/${targetUid}/`, `avatars/${targetUid}`],
      },
    });

    functions.logger.info("User cascade-deleted", { callerUid, targetUid });

    return { success: true };
  }
);

async function deleteCollection(path: string, batchSize = 200): Promise<void> {
  const collRef = db.collection(path);
  let query = collRef.orderBy("__name__").limit(batchSize);

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

async function deleteUserFiles(uid: string): Promise<void> {
  const bucket = storage.bucket();
  const prefixes = [`users/${uid}/`, `avatars/${uid}`];

  for (const prefix of prefixes) {
    try {
      await bucket.deleteFiles({ prefix, force: true });
    } catch (err) {
      functions.logger.warn("Failed to delete user storage files", {
        uid,
        prefix,
        error: err,
      });
    }
  }
}
