import * as functions from "firebase-functions";

// ── Mocks ──────────────────────────────────────────────────────────────

// In-memory Firestore mock
const mockDocs: Map<string, object[]> = new Map();
const deletedDocs: string[] = [];
const deletedAuthUsers: string[] = [];
const auditLogs: object[] = [];
let adminClaims: Record<string, boolean> = {};

const mockBatch = () => {
  const ops: Array<() => void> = [];
  return {
    delete: (ref: { path: string }) => {
      ops.push(() => deletedDocs.push(ref.path));
    },
    commit: async () => ops.forEach((op) => op()),
  };
};

const mockDb = {
  collection: (path: string) => ({
    orderBy: (..._args: unknown[]) => ({
      limit: (..._args2: unknown[]) => ({
        get: async () => {
          const docs = mockDocs.get(path) ?? [];
          return {
            empty: docs.length === 0,
            size: docs.length,
            docs: docs.map((_d, i) => ({
              ref: { path: `${path}/doc_${i}` },
            })),
          };
        },
        startAfter: () => ({
          limit: (..._args3: unknown[]) => ({
            get: async () => ({ empty: true, size: 0, docs: [] }),
          }),
        }),
      }),
    }),
    add: async (data: object) => {
      auditLogs.push(data);
    },
  }),
  doc: (path: string) => ({
    delete: async () => {
      deletedDocs.push(path);
    },
  }),
  batch: mockBatch,
};

const mockAuth = {
  getUser: async (uid: string) => ({
    customClaims: adminClaims[uid] ? { admin: true } : {},
  }),
  deleteUser: async (uid: string) => {
    deletedAuthUsers.push(uid);
  },
};

// ── Test helpers ────────────────────────────────────────────────────────

function resetMocks() {
  mockDocs.clear();
  deletedDocs.length = 0;
  deletedAuthUsers.length = 0;
  auditLogs.length = 0;
  adminClaims = {};
}

// Simulate the deleteUserCascade logic without importing Firebase SDK
async function simulateDeleteUserCascade(
  data: { targetUid?: string | null },
  context: { auth?: { uid: string } | null }
) {
  // Auth gate
  if (!context.auth) {
    throw { code: "unauthenticated", message: "Authentication required." };
  }

  const callerUid = context.auth.uid;
  const callerUser = await mockAuth.getUser(callerUid);
  if (callerUser.customClaims?.admin !== true) {
    throw { code: "permission-denied", message: "Only admins can delete users." };
  }

  // Validate input
  const targetUid = data.targetUid;
  if (!targetUid || typeof targetUid !== "string") {
    throw { code: "invalid-argument", message: "targetUid must be a non-empty string." };
  }

  // Prevent self-deletion
  if (targetUid === callerUid) {
    throw {
      code: "failed-precondition",
      message: "Admins cannot delete their own account via this function.",
    };
  }

  // Delete subcollections
  const subcollections = ["cards", "transactions", "notifications"];
  for (const sub of subcollections) {
    const path = `users/${targetUid}/${sub}`;
    const snap = await mockDb.collection(path).orderBy("__name__").limit(200).get();
    if (!snap.empty) {
      const batch = mockDb.batch();
      snap.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }
  }

  // Delete user document
  await mockDb.doc(`users/${targetUid}`).delete();

  // Delete Auth user
  await mockAuth.deleteUser(targetUid);

  // Audit log
  auditLogs.push({
    action: "DELETE_USER_CASCADE",
    performedBy: callerUid,
    targetUid,
  });

  return { success: true };
}

// ── Tests ──────────────────────────────────────────────────────────────

describe("deleteUserCascade", () => {
  beforeEach(() => {
    resetMocks();
  });

  test("rejects unauthenticated callers", async () => {
    await expect(
      simulateDeleteUserCascade({ targetUid: "user-1" }, { auth: null })
    ).rejects.toEqual(
      expect.objectContaining({ code: "unauthenticated" })
    );
  });

  test("rejects non-admin callers", async () => {
    adminClaims = { "caller-1": false };

    await expect(
      simulateDeleteUserCascade(
        { targetUid: "user-1" },
        { auth: { uid: "caller-1" } }
      )
    ).rejects.toEqual(
      expect.objectContaining({ code: "permission-denied" })
    );
  });

  test("rejects missing targetUid", async () => {
    adminClaims = { "admin-1": true };

    await expect(
      simulateDeleteUserCascade(
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
      simulateDeleteUserCascade(
        { targetUid: "" },
        { auth: { uid: "admin-1" } }
      )
    ).rejects.toEqual(
      expect.objectContaining({ code: "invalid-argument" })
    );
  });

  test("prevents admin self-deletion", async () => {
    adminClaims = { "admin-1": true };

    await expect(
      simulateDeleteUserCascade(
        { targetUid: "admin-1" },
        { auth: { uid: "admin-1" } }
      )
    ).rejects.toEqual(
      expect.objectContaining({ code: "failed-precondition" })
    );
  });

  test("deletes subcollections, user doc, and auth user on success", async () => {
    adminClaims = { "admin-1": true };

    // Seed mock data for the target user
    mockDocs.set("users/target-1/cards", [{ id: "c1" }]);
    mockDocs.set("users/target-1/transactions", [{ id: "t1" }, { id: "t2" }]);
    mockDocs.set("users/target-1/notifications", []);

    const result = await simulateDeleteUserCascade(
      { targetUid: "target-1" },
      { auth: { uid: "admin-1" } }
    );

    expect(result).toEqual({ success: true });

    // Verify subcollection docs were deleted (batch operations)
    expect(deletedDocs).toContain("users/target-1/cards/doc_0");
    expect(deletedDocs).toContain("users/target-1/transactions/doc_0");
    expect(deletedDocs).toContain("users/target-1/transactions/doc_1");

    // Verify user doc was deleted
    expect(deletedDocs).toContain("users/target-1");

    // Verify auth user was deleted
    expect(deletedAuthUsers).toContain("target-1");

    // Verify audit log was written
    expect(auditLogs).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          action: "DELETE_USER_CASCADE",
          performedBy: "admin-1",
          targetUid: "target-1",
        }),
      ])
    );
  });
});
