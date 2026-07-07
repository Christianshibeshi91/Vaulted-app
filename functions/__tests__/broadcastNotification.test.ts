// ── Mocks ──────────────────────────────────────────────────────────────

let adminClaims: Record<string, boolean> = {};
let mockUsers: Array<{ id: string; data: Record<string, unknown> }> = [];
let writtenNotifications: object[] = [];
let sentFcmMessages: object[] = [];
let auditLogs: object[] = [];

function resetMocks() {
  adminClaims = {};
  mockUsers = [];
  writtenNotifications = [];
  sentFcmMessages = [];
  auditLogs = [];
}

// Simulates broadcastNotification logic
async function simulateBroadcastNotification(
  data: { title?: string | null; body?: string | null; type?: string; data?: Record<string, string> },
  context: { auth?: { uid: string } | null }
) {
  // Auth gate
  if (!context.auth) {
    throw { code: "unauthenticated", message: "Authentication required." };
  }

  const callerUid = context.auth.uid;
  if (!adminClaims[callerUid]) {
    throw { code: "permission-denied", message: "Only admins can broadcast notifications." };
  }

  // Validate input
  if (!data.title || typeof data.title !== "string") {
    throw { code: "invalid-argument", message: "title is required and must be a string." };
  }
  if (!data.body || typeof data.body !== "string") {
    throw { code: "invalid-argument", message: "body is required and must be a string." };
  }

  const notificationType = data.type ?? "system_broadcast";
  const fcmTokens: string[] = [];
  let written = 0;

  for (const userDoc of mockUsers) {
    writtenNotifications.push({
      userId: userDoc.id,
      type: notificationType,
      title: data.title,
      body: data.body,
      isRead: false,
    });
    written++;

    const userData = userDoc.data;
    if (userData.fcmToken && typeof userData.fcmToken === "string") {
      fcmTokens.push(userData.fcmToken as string);
    }
  }

  // Simulate FCM sends
  let fcmSuccess = 0;
  let fcmFailed = 0;

  for (const token of fcmTokens) {
    sentFcmMessages.push({ token, title: data.title, body: data.body });
    fcmSuccess++;
  }

  auditLogs.push({
    action: "BROADCAST_NOTIFICATION",
    performedBy: callerUid,
    recipientCount: written,
    fcmSuccess,
    fcmFailed,
  });

  return { success: true, written, fcmSuccess, fcmFailed };
}

// ── Tests ──────────────────────────────────────────────────────────────

describe("broadcastNotification", () => {
  beforeEach(() => {
    resetMocks();
  });

  test("rejects unauthenticated callers", async () => {
    await expect(
      simulateBroadcastNotification(
        { title: "Test", body: "Hello" },
        { auth: null }
      )
    ).rejects.toEqual(
      expect.objectContaining({ code: "unauthenticated" })
    );
  });

  test("rejects non-admin callers", async () => {
    adminClaims = { "user-1": false };

    await expect(
      simulateBroadcastNotification(
        { title: "Test", body: "Hello" },
        { auth: { uid: "user-1" } }
      )
    ).rejects.toEqual(
      expect.objectContaining({ code: "permission-denied" })
    );
  });

  test("rejects missing title", async () => {
    adminClaims = { "admin-1": true };

    await expect(
      simulateBroadcastNotification(
        { title: null, body: "Hello" },
        { auth: { uid: "admin-1" } }
      )
    ).rejects.toEqual(
      expect.objectContaining({ code: "invalid-argument" })
    );
  });

  test("rejects missing body", async () => {
    adminClaims = { "admin-1": true };

    await expect(
      simulateBroadcastNotification(
        { title: "Test", body: null },
        { auth: { uid: "admin-1" } }
      )
    ).rejects.toEqual(
      expect.objectContaining({ code: "invalid-argument" })
    );
  });

  test("writes notification to all users and sends FCM", async () => {
    adminClaims = { "admin-1": true };
    mockUsers = [
      { id: "user-1", data: { fcmToken: "token-1" } },
      { id: "user-2", data: { fcmToken: "token-2" } },
      { id: "user-3", data: {} }, // No FCM token
    ];

    const result = await simulateBroadcastNotification(
      { title: "System Update", body: "New features available!" },
      { auth: { uid: "admin-1" } }
    );

    expect(result.success).toBe(true);
    expect(result.written).toBe(3);
    expect(result.fcmSuccess).toBe(2);
    expect(result.fcmFailed).toBe(0);

    // All users got a notification
    expect(writtenNotifications).toHaveLength(3);
    expect(writtenNotifications[0]).toEqual(
      expect.objectContaining({
        userId: "user-1",
        title: "System Update",
        isRead: false,
      })
    );

    // Only users with FCM tokens got push
    expect(sentFcmMessages).toHaveLength(2);

    // Audit log written
    expect(auditLogs).toHaveLength(1);
    expect(auditLogs[0]).toEqual(
      expect.objectContaining({
        action: "BROADCAST_NOTIFICATION",
        performedBy: "admin-1",
        recipientCount: 3,
      })
    );
  });

  test("defaults notification type to system_broadcast", async () => {
    adminClaims = { "admin-1": true };
    mockUsers = [{ id: "user-1", data: {} }];

    await simulateBroadcastNotification(
      { title: "Test", body: "Body" },
      { auth: { uid: "admin-1" } }
    );

    expect(writtenNotifications[0]).toEqual(
      expect.objectContaining({ type: "system_broadcast" })
    );
  });

  test("uses custom notification type when provided", async () => {
    adminClaims = { "admin-1": true };
    mockUsers = [{ id: "user-1", data: {} }];

    await simulateBroadcastNotification(
      { title: "Test", body: "Body", type: "promotion" },
      { auth: { uid: "admin-1" } }
    );

    expect(writtenNotifications[0]).toEqual(
      expect.objectContaining({ type: "promotion" })
    );
  });
});
