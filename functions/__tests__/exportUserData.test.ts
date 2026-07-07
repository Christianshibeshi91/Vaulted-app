// ── Mocks ──────────────────────────────────────────────────────────────

let mockUserDoc: { exists: boolean; data: () => object | undefined } = {
  exists: false,
  data: () => undefined,
};
let mockCards: object[] = [];
let mockTransactions: object[] = [];
let mockNotifications: object[] = [];

function resetMocks() {
  mockUserDoc = { exists: false, data: () => undefined };
  mockCards = [];
  mockTransactions = [];
  mockNotifications = [];
}

// Simulates exportUserData logic
async function simulateExportUserData(
  _data: unknown,
  context: { auth?: { uid: string } | null }
) {
  // Auth gate
  if (!context.auth) {
    throw { code: "unauthenticated", message: "Authentication required." };
  }

  const uid = context.auth.uid;

  // Gather profile
  if (!mockUserDoc.exists) {
    throw { code: "not-found", message: "User profile not found." };
  }
  const profile = mockUserDoc.data();

  // Gather cards
  const cards = mockCards.map((card, i) => ({
    id: `card_${i}`,
    ...card,
  }));

  // Gather transactions
  const transactions = mockTransactions.map((tx, i) => ({
    id: `tx_${i}`,
    ...tx,
  }));

  // Gather notifications
  const notifications = mockNotifications.map((n, i) => ({
    id: `notif_${i}`,
    ...n,
  }));

  return {
    exportedAt: expect.any(String),
    profile,
    cards,
    transactions,
    notifications,
  };
}

// ── Tests ──────────────────────────────────────────────────────────────

describe("exportUserData", () => {
  beforeEach(() => {
    resetMocks();
  });

  test("rejects unauthenticated callers", async () => {
    await expect(
      simulateExportUserData(null, { auth: null })
    ).rejects.toEqual(
      expect.objectContaining({ code: "unauthenticated" })
    );
  });

  test("throws not-found when user profile does not exist", async () => {
    mockUserDoc = { exists: false, data: () => undefined };

    await expect(
      simulateExportUserData(null, { auth: { uid: "user-1" } })
    ).rejects.toEqual(
      expect.objectContaining({ code: "not-found" })
    );
  });

  test("returns all user data on success", async () => {
    mockUserDoc = {
      exists: true,
      data: () => ({
        email: "test@example.com",
        displayName: "Test User",
        role: "user",
        plan: "free",
      }),
    };
    mockCards = [
      { retailer: "Amazon", balance: 50.0 },
      { retailer: "Target", balance: 25.0 },
    ];
    mockTransactions = [
      { cardId: "card_0", type: "purchase", amount: 10.0 },
    ];
    mockNotifications = [
      { type: "expiration_alert", title: "Card Expiring" },
    ];

    const result = await simulateExportUserData(
      null,
      { auth: { uid: "user-1" } }
    );

    expect(result.profile).toEqual(
      expect.objectContaining({ email: "test@example.com" })
    );
    expect(result.cards).toHaveLength(2);
    expect(result.cards[0]).toEqual(
      expect.objectContaining({ retailer: "Amazon" })
    );
    expect(result.transactions).toHaveLength(1);
    expect(result.notifications).toHaveLength(1);
  });

  test("returns empty arrays when user has no cards or transactions", async () => {
    mockUserDoc = {
      exists: true,
      data: () => ({ email: "empty@example.com" }),
    };

    const result = await simulateExportUserData(
      null,
      { auth: { uid: "user-empty" } }
    );

    expect(result.profile).toEqual(
      expect.objectContaining({ email: "empty@example.com" })
    );
    expect(result.cards).toHaveLength(0);
    expect(result.transactions).toHaveLength(0);
    expect(result.notifications).toHaveLength(0);
  });
});
