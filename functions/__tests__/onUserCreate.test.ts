// ── Mocks ──────────────────────────────────────────────────────────────

const firestoreDocs: Map<string, Record<string, unknown>> = new Map();
const SERVER_TIMESTAMP = Symbol("SERVER_TIMESTAMP");

const mockDb = {
  doc: (path: string) => ({
    set: async (data: Record<string, unknown>) => {
      firestoreDocs.set(path, data);
    },
  }),
};

function resetMocks() {
  firestoreDocs.clear();
}

// ── Simulation of onUserCreate logic ──────────────────────────────────

interface AuthUser {
  uid: string;
  email?: string | null;
  displayName?: string | null;
}

async function simulateOnUserCreate(user: AuthUser) {
  const { uid, email, displayName } = user;

  const userDoc: Record<string, unknown> = {
    email: email ?? null,
    displayName: displayName ?? null,
    role: "user",
    plan: "free",

    // Security
    mfaEnabled: false,
    biometricEnabled: false,

    // Onboarding
    onboardingComplete: false,

    // Notification preferences
    notificationPreferences: {
      push: true,
      email: true,
      expirationAlerts: true,
      promotions: false,
    },

    // Timestamps
    createdAt: SERVER_TIMESTAMP,
    updatedAt: SERVER_TIMESTAMP,
    lastLoginAt: SERVER_TIMESTAMP,

    // Metrics
    loginCount: 0,

    // Status
    isSuspended: false,
  };

  await mockDb.doc(`users/${uid}`).set(userDoc);
}

// ── Tests ──────────────────────────────────────────────────────────────

describe("onUserCreate", () => {
  beforeEach(() => {
    resetMocks();
  });

  test("creates user doc at /users/{uid} with correct default fields", async () => {
    await simulateOnUserCreate({
      uid: "user-abc",
      email: "alice@example.com",
      displayName: "Alice",
    });

    expect(firestoreDocs.has("users/user-abc")).toBe(true);

    const doc = firestoreDocs.get("users/user-abc")!;
    expect(doc.email).toBe("alice@example.com");
    expect(doc.displayName).toBe("Alice");
    expect(doc.role).toBe("user");
    expect(doc.plan).toBe("free");
    expect(doc.loginCount).toBe(0);
    expect(doc.onboardingComplete).toBe(false);
    expect(doc.biometricEnabled).toBe(false);
  });

  test("default role is 'user' (not 'admin')", async () => {
    await simulateOnUserCreate({
      uid: "user-1",
      email: "user@example.com",
      displayName: "Regular User",
    });

    const doc = firestoreDocs.get("users/user-1")!;
    expect(doc.role).toBe("user");
    expect(doc.role).not.toBe("admin");
  });

  test("default plan is 'free'", async () => {
    await simulateOnUserCreate({
      uid: "user-2",
      email: "user2@example.com",
      displayName: "Free User",
    });

    const doc = firestoreDocs.get("users/user-2")!;
    expect(doc.plan).toBe("free");
  });

  test("mfaEnabled defaults to false", async () => {
    await simulateOnUserCreate({
      uid: "user-3",
      email: "user3@example.com",
      displayName: "User Three",
    });

    const doc = firestoreDocs.get("users/user-3")!;
    expect(doc.mfaEnabled).toBe(false);
  });

  test("isSuspended defaults to false", async () => {
    await simulateOnUserCreate({
      uid: "user-4",
      email: "user4@example.com",
      displayName: "User Four",
    });

    const doc = firestoreDocs.get("users/user-4")!;
    expect(doc.isSuspended).toBe(false);
  });

  test("notificationPreferences set with correct defaults", async () => {
    await simulateOnUserCreate({
      uid: "user-5",
      email: "user5@example.com",
      displayName: "User Five",
    });

    const doc = firestoreDocs.get("users/user-5")!;
    const prefs = doc.notificationPreferences as Record<string, boolean>;

    expect(prefs).toEqual({
      push: true,
      email: true,
      expirationAlerts: true,
      promotions: false,
    });
  });

  test("handles null displayName gracefully", async () => {
    await simulateOnUserCreate({
      uid: "user-6",
      email: "nodisplay@example.com",
      displayName: null,
    });

    const doc = firestoreDocs.get("users/user-6")!;
    expect(doc.displayName).toBeNull();
    // All other fields should still be set correctly
    expect(doc.email).toBe("nodisplay@example.com");
    expect(doc.role).toBe("user");
    expect(doc.plan).toBe("free");
  });

  test("handles undefined displayName gracefully", async () => {
    await simulateOnUserCreate({
      uid: "user-7",
      email: "undef@example.com",
      displayName: undefined,
    });

    const doc = firestoreDocs.get("users/user-7")!;
    expect(doc.displayName).toBeNull();
  });

  test("handles null email gracefully", async () => {
    await simulateOnUserCreate({
      uid: "user-8",
      email: null,
      displayName: "No Email",
    });

    const doc = firestoreDocs.get("users/user-8")!;
    expect(doc.email).toBeNull();
    expect(doc.displayName).toBe("No Email");
  });

  test("timestamps are set to server timestamp sentinel", async () => {
    await simulateOnUserCreate({
      uid: "user-9",
      email: "ts@example.com",
      displayName: "Timestamps",
    });

    const doc = firestoreDocs.get("users/user-9")!;
    expect(doc.createdAt).toBe(SERVER_TIMESTAMP);
    expect(doc.updatedAt).toBe(SERVER_TIMESTAMP);
    expect(doc.lastLoginAt).toBe(SERVER_TIMESTAMP);
  });
});
