// ── Mocks ──────────────────────────────────────────────────────────────

let authUsers: Record<string, { customClaims?: Record<string, unknown> }> = {};
let firestoreDocs: Map<string, Record<string, unknown> | undefined> = new Map();
let collectionDocs: Array<Record<string, unknown>> = [];
const SERVER_TIMESTAMP = Symbol("SERVER_TIMESTAMP");

const mockAuth = {
  getUser: async (uid: string) => {
    const user = authUsers[uid];
    if (!user) throw new Error(`User ${uid} not found`);
    return user;
  },
};

const mockDb = {
  doc: (path: string) => ({
    get: async () => {
      const data = firestoreDocs.get(path);
      return {
        exists: data !== undefined,
        data: () => data,
      };
    },
  }),
  collection: (path: string) => ({
    add: async (data: Record<string, unknown>) => {
      collectionDocs.push({ _path: path, ...data });
    },
  }),
};

function resetMocks() {
  authUsers = {};
  firestoreDocs = new Map();
  collectionDocs = [];
}

// ── Simulation of admin utility functions ─────────────────────────────

async function simulateIsAdmin(uid: string): Promise<boolean> {
  const user = await mockAuth.getUser(uid);
  return user.customClaims?.admin === true;
}

async function simulateGetAdminUsers(): Promise<string[]> {
  const snap = await mockDb.doc("admin/config").get();
  if (!snap.exists) return [];
  const data = snap.data();
  const adminUids = data?.adminUids;
  if (!Array.isArray(adminUids)) return [];
  return adminUids.filter((uid): uid is string => typeof uid === "string");
}

function simulateGetPushToken(
  data: Record<string, unknown> | undefined
): string | null {
  if (!data) return null;

  const candidates = [data.fcmToken, data.pushToken];
  for (const candidate of candidates) {
    if (typeof candidate === "string" && candidate.trim().length > 0) {
      return candidate.trim();
    }
  }

  return null;
}

interface AuditEntry {
  action: string;
  performedBy: string;
  targetUid?: string;
  details?: Record<string, unknown>;
}

async function simulateWriteAuditLog(entry: AuditEntry): Promise<void> {
  await mockDb.collection("admin/auditLog/entries").add({
    ...entry,
    timestamp: SERVER_TIMESTAMP,
  });
}

// ── Tests ──────────────────────────────────────────────────────────────

describe("isAdmin", () => {
  beforeEach(() => {
    resetMocks();
  });

  test("returns true for user with admin custom claim", async () => {
    authUsers["admin-1"] = { customClaims: { admin: true } };

    const result = await simulateIsAdmin("admin-1");
    expect(result).toBe(true);
  });

  test("returns false for user without admin claim", async () => {
    authUsers["regular-1"] = { customClaims: {} };

    const result = await simulateIsAdmin("regular-1");
    expect(result).toBe(false);
  });

  test("returns false for user with admin claim set to false", async () => {
    authUsers["user-2"] = { customClaims: { admin: false } };

    const result = await simulateIsAdmin("user-2");
    expect(result).toBe(false);
  });

  test("returns false for user with no customClaims at all", async () => {
    authUsers["user-3"] = {};

    const result = await simulateIsAdmin("user-3");
    expect(result).toBe(false);
  });
});

describe("getAdminUsers", () => {
  beforeEach(() => {
    resetMocks();
  });

  test("returns empty array when config doc does not exist", async () => {
    // Do not set "admin/config" in firestoreDocs
    const result = await simulateGetAdminUsers();
    expect(result).toEqual([]);
  });

  test("returns empty array when adminUids field is missing", async () => {
    firestoreDocs.set("admin/config", { someOtherField: "value" });

    const result = await simulateGetAdminUsers();
    expect(result).toEqual([]);
  });

  test("returns empty array when adminUids is not an array", async () => {
    firestoreDocs.set("admin/config", { adminUids: "not-an-array" });

    const result = await simulateGetAdminUsers();
    expect(result).toEqual([]);
  });

  test("returns array of admin UIDs from config doc", async () => {
    firestoreDocs.set("admin/config", {
      adminUids: ["admin-1", "admin-2", "admin-3"],
    });

    const result = await simulateGetAdminUsers();
    expect(result).toEqual(["admin-1", "admin-2", "admin-3"]);
  });

  test("filters out non-string values from adminUids", async () => {
    firestoreDocs.set("admin/config", {
      adminUids: ["admin-1", 42, null, "admin-2", undefined, true],
    });

    const result = await simulateGetAdminUsers();
    expect(result).toEqual(["admin-1", "admin-2"]);
  });
});

describe("getPushToken", () => {
  beforeEach(() => {
    resetMocks();
  });

  test("returns fcmToken when present", () => {
    const result = simulateGetPushToken({
      fcmToken: "fcm-abc-123",
      pushToken: "push-xyz-789",
    });
    expect(result).toBe("fcm-abc-123");
  });

  test("returns pushToken when fcmToken is absent", () => {
    const result = simulateGetPushToken({
      pushToken: "push-xyz-789",
    });
    expect(result).toBe("push-xyz-789");
  });

  test("returns null when neither token exists", () => {
    const result = simulateGetPushToken({ email: "test@example.com" });
    expect(result).toBeNull();
  });

  test("returns null for undefined data", () => {
    const result = simulateGetPushToken(undefined);
    expect(result).toBeNull();
  });

  test("returns null for empty string fcmToken, falls back to pushToken", () => {
    const result = simulateGetPushToken({
      fcmToken: "",
      pushToken: "push-valid",
    });
    expect(result).toBe("push-valid");
  });

  test("returns null for empty string tokens", () => {
    const result = simulateGetPushToken({
      fcmToken: "",
      pushToken: "",
    });
    expect(result).toBeNull();
  });

  test("returns null for whitespace-only tokens", () => {
    const result = simulateGetPushToken({
      fcmToken: "   ",
      pushToken: "  \t  ",
    });
    expect(result).toBeNull();
  });

  test("trims whitespace from valid tokens", () => {
    const result = simulateGetPushToken({
      fcmToken: "  token-with-spaces  ",
    });
    expect(result).toBe("token-with-spaces");
  });

  test("skips null fcmToken and returns pushToken", () => {
    const result = simulateGetPushToken({
      fcmToken: null,
      pushToken: "fallback-push",
    });
    expect(result).toBe("fallback-push");
  });
});

describe("writeAuditLog", () => {
  beforeEach(() => {
    resetMocks();
  });

  test("writes entry with server timestamp to audit log collection", async () => {
    await simulateWriteAuditLog({
      action: "SET_ADMIN_CLAIM",
      performedBy: "admin-1",
      targetUid: "user-42",
      details: { grantedAdmin: true },
    });

    expect(collectionDocs).toHaveLength(1);
    expect(collectionDocs[0]).toEqual(
      expect.objectContaining({
        _path: "admin/auditLog/entries",
        action: "SET_ADMIN_CLAIM",
        performedBy: "admin-1",
        targetUid: "user-42",
        details: { grantedAdmin: true },
        timestamp: SERVER_TIMESTAMP,
      })
    );
  });

  test("writes entry without optional fields", async () => {
    await simulateWriteAuditLog({
      action: "SYSTEM_EVENT",
      performedBy: "system",
    });

    expect(collectionDocs).toHaveLength(1);
    expect(collectionDocs[0]).toEqual(
      expect.objectContaining({
        action: "SYSTEM_EVENT",
        performedBy: "system",
        timestamp: SERVER_TIMESTAMP,
      })
    );
    expect(collectionDocs[0]).not.toHaveProperty("targetUid");
  });

  test("multiple audit entries are all recorded", async () => {
    await simulateWriteAuditLog({
      action: "ACTION_A",
      performedBy: "admin-1",
    });
    await simulateWriteAuditLog({
      action: "ACTION_B",
      performedBy: "admin-2",
    });

    expect(collectionDocs).toHaveLength(2);
    expect(collectionDocs[0]).toEqual(
      expect.objectContaining({ action: "ACTION_A" })
    );
    expect(collectionDocs[1]).toEqual(
      expect.objectContaining({ action: "ACTION_B" })
    );
  });
});
