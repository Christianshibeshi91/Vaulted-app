import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK (idempotent — safe to call from multiple modules)
if (!admin.apps.length) {
  admin.initializeApp();
}

export const db = admin.firestore();
export const auth = admin.auth();
export const messaging = admin.messaging();

// ─── Admin helpers ───────────────────────────────────────────────

/**
 * Check whether a user has the admin custom claim.
 */
export async function isAdmin(uid: string): Promise<boolean> {
  const user = await auth.getUser(uid);
  return user.customClaims?.admin === true;
}

/**
 * Return all users whose custom claims include admin: true.
 * Firebase Auth has no "query by claim" API, so we read from
 * the /admin/config/adminUids Firestore doc instead.
 */
export async function getAdminUsers(): Promise<string[]> {
  const snap = await db.doc("admin/config").get();
  if (!snap.exists) return [];
  const data = snap.data();
  return (data?.adminUids as string[]) ?? [];
}

// ─── Audit log writer ────────────────────────────────────────────

interface AuditEntry {
  action: string;
  performedBy: string;
  targetUid?: string;
  details?: Record<string, unknown>;
}

/**
 * Write an immutable audit-log entry under /admin/auditLog/entries.
 */
export async function writeAuditLog(entry: AuditEntry): Promise<void> {
  await db.collection("admin/auditLog/entries").add({
    ...entry,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}
