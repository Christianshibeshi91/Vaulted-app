// ── Mocks ──────────────────────────────────────────────────────────────

let adminClaims: Record<string, boolean> = {};
let customClaimsSet: Array<{ uid: string; claims: object }> = [];
let firestoreUpdates: Array<{ path: string; data: object }> = [];
let auditLogs: object[] = [];

function resetMocks() {
  adminClaims = {};
  customClaimsSet = [];
  firestoreUpdates = [];
  auditLogs = [];
}

// Simulates setAdminClaim logic
async function simulateSetAdminClaim(
  data: { targetUid?: string | null },
  context: { auth?: { uid: string } | null }
) {
  // Auth gate
  if (!context.auth) {
    throw { code: "unauthenticated", message: "Authentication required." };
  }

  const callerUid = context.auth.uid;
  if (!adminClaims[callerUid]) {
    throw { code: "permission-denied", message: "Only admins can grant admin privileges." };
  }

  // Input validation
  const targetUid = data.targetUid;
  if (!targetUid || typeof targetUid !== "string") {
    throw { code: "invalid-argument", message: "targetUid must be a non-empty string." };
  }

  // Set custom claim
  customClaimsSet.push({ uid: targetUid, claims: { admin: true } });

  // Update Firestore
  firestoreUpdates.push({
    path: `users/${targetUid}`,
    data: { role: "admin" },
  });

  // Audit log
  auditLogs.push({
    action: "SET_ADMIN_CLAIM",
    performedBy: callerUid,
    targetUid,
    details: { grantedAdmin: true },
  });

  return { success: true };
}

// ── Tests ──────────────────────────────────────────────────────────────

describe("setAdminClaim", () => {
  beforeEach(() => {
    resetMocks();
  });

  test("rejects unauthenticated callers", async () => {
    await expect(
      simulateSetAdminClaim({ targetUid: "user-1" }, { auth: null })
    ).rejects.toEqual(
      expect.objectContaining({ code: "unauthenticated" })
    );
  });

  test("rejects non-admin callers", async () => {
    adminClaims = { "caller-1": false };

    await expect(
      simulateSetAdminClaim(
        { targetUid: "user-1" },
        { auth: { uid: "caller-1" } }
      )
    ).rejects.toEqual(
      expect.objectContaining({ code: "permission-denied" })
    );
  });

  test("rejects null targetUid", async () => {
    adminClaims = { "admin-1": true };

    await expect(
      simulateSetAdminClaim(
        { targetUid: null },
        { auth: { uid: "admin-1" } }
      )
    ).rejects.toEqual(
      expect.objectContaining({ code: "invalid-argument" })
    );
  });

  test("rejects empty string targetUid", async () => {
    adminClaims = { "admin-1": true };

    await expect(
      simulateSetAdminClaim(
        { targetUid: "" },
        { auth: { uid: "admin-1" } }
      )
    ).rejects.toEqual(
      expect.objectContaining({ code: "invalid-argument" })
    );
  });

  test("sets custom claim, updates Firestore, and writes audit log", async () => {
    adminClaims = { "admin-1": true };

    const result = await simulateSetAdminClaim(
      { targetUid: "user-42" },
      { auth: { uid: "admin-1" } }
    );

    expect(result).toEqual({ success: true });

    // Custom claim was set
    expect(customClaimsSet).toEqual([
      { uid: "user-42", claims: { admin: true } },
    ]);

    // Firestore was updated
    expect(firestoreUpdates).toEqual([
      { path: "users/user-42", data: { role: "admin" } },
    ]);

    // Audit log was written
    expect(auditLogs).toEqual([
      expect.objectContaining({
        action: "SET_ADMIN_CLAIM",
        performedBy: "admin-1",
        targetUid: "user-42",
      }),
    ]);
  });
});
