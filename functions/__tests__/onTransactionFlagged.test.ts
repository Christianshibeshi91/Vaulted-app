// ── Mocks ──────────────────────────────────────────────────────────────

let createdAlerts: object[] = [];
let sentFcmMessages: object[] = [];
let adminUids: string[] = [];
let adminFcmTokens: Record<string, string | null> = {};

function resetMocks() {
  createdAlerts = [];
  sentFcmMessages = [];
  adminUids = [];
  adminFcmTokens = {};
}

// Simulates onTransactionFlagged trigger logic
async function simulateOnTransactionFlagged(
  before: Record<string, unknown>,
  after: Record<string, unknown>,
  params: { userId: string; transactionId: string }
) {
  // Only fire when status transitions TO "flagged"
  if (before.status === "flagged" || after.status !== "flagged") {
    return { skipped: true };
  }

  const { userId, transactionId } = params;

  // Create admin alert
  createdAlerts.push({
    type: "fraud",
    severity: "high",
    title: "Transaction Flagged",
    message: `Transaction ${transactionId} for user ${userId} was flagged. Amount: $${after.amount}, Retailer: ${after.retailer ?? "unknown"}.`,
    isResolved: false,
    userId,
    transactionId,
  });

  // Notify admin users via FCM
  for (const adminUid of adminUids) {
    const fcmToken = adminFcmTokens[adminUid];
    if (fcmToken) {
      sentFcmMessages.push({
        token: fcmToken,
        title: "Transaction Flagged",
        body: `User ${userId}: $${after.amount} at ${after.retailer ?? "unknown"}`,
        data: { type: "flagged_transaction", userId, transactionId },
      });
    }
  }

  return { processed: true };
}

// ── Tests ──────────────────────────────────────────────────────────────

describe("onTransactionFlagged", () => {
  beforeEach(() => {
    resetMocks();
  });

  test("skips when status was already flagged", async () => {
    const result = await simulateOnTransactionFlagged(
      { status: "flagged", amount: 50 },
      { status: "flagged", amount: 50 },
      { userId: "user-1", transactionId: "tx-1" }
    );

    expect(result).toEqual({ skipped: true });
    expect(createdAlerts).toHaveLength(0);
  });

  test("skips when status changes to something other than flagged", async () => {
    const result = await simulateOnTransactionFlagged(
      { status: "pending", amount: 50 },
      { status: "completed", amount: 50 },
      { userId: "user-1", transactionId: "tx-1" }
    );

    expect(result).toEqual({ skipped: true });
    expect(createdAlerts).toHaveLength(0);
  });

  test("creates admin alert when transaction is flagged", async () => {
    adminUids = [];

    const result = await simulateOnTransactionFlagged(
      { status: "pending", amount: 99.99, retailer: "Amazon" },
      { status: "flagged", amount: 99.99, retailer: "Amazon" },
      { userId: "user-1", transactionId: "tx-42" }
    );

    expect(result).toEqual({ processed: true });
    expect(createdAlerts).toHaveLength(1);
    expect(createdAlerts[0]).toEqual(
      expect.objectContaining({
        type: "fraud",
        severity: "high",
        title: "Transaction Flagged",
        isResolved: false,
        userId: "user-1",
        transactionId: "tx-42",
      })
    );
    expect((createdAlerts[0] as { message: string }).message).toContain("$99.99");
    expect((createdAlerts[0] as { message: string }).message).toContain("Amazon");
  });

  test("sends FCM to admin users with tokens", async () => {
    adminUids = ["admin-1", "admin-2", "admin-3"];
    adminFcmTokens = {
      "admin-1": "fcm-token-1",
      "admin-2": null, // No token
      "admin-3": "fcm-token-3",
    };

    await simulateOnTransactionFlagged(
      { status: "pending", amount: 25.0 },
      { status: "flagged", amount: 25.0, retailer: "Target" },
      { userId: "user-5", transactionId: "tx-99" }
    );

    // Only admin-1 and admin-3 have FCM tokens
    expect(sentFcmMessages).toHaveLength(2);
    expect(sentFcmMessages[0]).toEqual(
      expect.objectContaining({
        token: "fcm-token-1",
        title: "Transaction Flagged",
      })
    );
    expect(sentFcmMessages[1]).toEqual(
      expect.objectContaining({
        token: "fcm-token-3",
      })
    );
  });

  test("handles missing retailer field gracefully", async () => {
    await simulateOnTransactionFlagged(
      { status: "completed", amount: 10.0 },
      { status: "flagged", amount: 10.0 },
      { userId: "user-1", transactionId: "tx-1" }
    );

    expect(createdAlerts).toHaveLength(1);
    expect((createdAlerts[0] as { message: string }).message).toContain("unknown");
  });
});
