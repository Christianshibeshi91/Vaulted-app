// ── Mocks ──────────────────────────────────────────────────────────────

interface MockCard {
  expirationDate: Date;
  retailer: string;
  balance: number;
}

interface MockUser {
  uid: string;
  data: Record<string, unknown>;
  cards: Map<string, MockCard>;
  notifications: Array<Record<string, unknown>>;
}

const SERVER_TIMESTAMP = Symbol("SERVER_TIMESTAMP");

let mockUsers: MockUser[] = [];
let createdNotifications: Array<{ uid: string; data: Record<string, unknown> }> = [];
let sentMessages: Array<Record<string, unknown>> = [];
let logWarnings: Array<Record<string, unknown>> = [];

function resetMocks() {
  mockUsers = [];
  createdNotifications = [];
  sentMessages = [];
  logWarnings = [];
}

// ── Helper: get push token (mirrors utils/admin.ts) ───────────────────

function getPushToken(data: Record<string, unknown> | undefined): string | null {
  if (!data) return null;
  const candidates = [data.fcmToken, data.pushToken];
  for (const candidate of candidates) {
    if (typeof candidate === "string" && candidate.trim().length > 0) {
      return candidate.trim();
    }
  }
  return null;
}

// ── Simulation of sendExpirationAlerts logic ──────────────────────────

async function simulateSendExpirationAlerts(nowOverride?: Date) {
  const now = nowOverride ?? new Date();
  const thirtyDaysFromNow = new Date(
    now.getTime() + 30 * 24 * 60 * 60 * 1000
  );

  let alertCount = 0;

  for (const user of mockUsers) {
    const uid = user.uid;
    const userData = user.data;

    // Skip users who opted out of expiration alerts
    if (userData.notificationPreferences &&
      (userData.notificationPreferences as Record<string, unknown>).expirationAlerts === false) {
      continue;
    }

    // Find cards expiring within 30 days
    const expiringCards: Array<{ id: string; card: MockCard }> = [];
    for (const [cardId, card] of user.cards) {
      const expDate = card.expirationDate;
      if (expDate >= now && expDate <= thirtyDaysFromNow) {
        expiringCards.push({ id: cardId, card });
      }
    }

    if (expiringCards.length === 0) continue;

    for (const { id: cardId, card } of expiringCards) {
      const daysLeft = Math.ceil(
        (card.expirationDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)
      );

      // Dedup: skip if an expiration alert was already sent for this card in the last 7 days
      const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      const alreadySent = user.notifications.some(
        (n) =>
          n.type === "expiration_alert" &&
          n.cardId === cardId &&
          n.createdAt instanceof Date &&
          (n.createdAt as Date) >= sevenDaysAgo
      );

      if (alreadySent) continue;

      // Create in-app notification
      const notification = {
        type: "expiration_alert",
        title: "Card Expiring Soon",
        body: `Your ${card.retailer} card ($${card.balance}) expires in ${daysLeft} day${daysLeft === 1 ? "" : "s"}.`,
        cardId,
        isRead: false,
        createdAt: SERVER_TIMESTAMP,
      };

      createdNotifications.push({ uid, data: notification });
      // Also add to user's notifications for dedup within the same run
      user.notifications.push({ ...notification, createdAt: now });

      alertCount++;
    }

    // Send FCM push if user has a token
    const pushToken = getPushToken(userData);
    if (pushToken) {
      try {
        const message = {
          token: pushToken,
          notification: {
            title: "Cards Expiring Soon",
            body: `You have ${expiringCards.length} card${expiringCards.length === 1 ? "" : "s"} expiring within 30 days.`,
          },
          data: {
            type: "expiration_alert",
            cardCount: String(expiringCards.length),
          },
        };
        sentMessages.push(message);
      } catch (err) {
        logWarnings.push({ uid, error: err });
      }
    }
  }

  return { alertCount };
}

// ── Test helpers ──────────────────────────────────────────────────────

function createMockUser(overrides: Partial<MockUser> & { uid: string }): MockUser {
  return {
    uid: overrides.uid,
    data: overrides.data ?? {
      notificationPreferences: {
        push: true,
        email: true,
        expirationAlerts: true,
        promotions: false,
      },
    },
    cards: overrides.cards ?? new Map(),
    notifications: overrides.notifications ?? [],
  };
}

function daysFromNow(days: number, base?: Date): Date {
  const now = base ?? new Date("2025-06-15T09:00:00Z");
  return new Date(now.getTime() + days * 24 * 60 * 60 * 1000);
}

// ── Tests ──────────────────────────────────────────────────────────────

describe("sendExpirationAlerts", () => {
  const NOW = new Date("2025-06-15T09:00:00Z");

  beforeEach(() => {
    resetMocks();
  });

  test("skips users who opted out of expiration alerts", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-1", {
      expirationDate: daysFromNow(10, NOW),
      retailer: "Amazon",
      balance: 50,
    });

    mockUsers = [
      createMockUser({
        uid: "opted-out-user",
        data: {
          notificationPreferences: {
            push: true,
            email: true,
            expirationAlerts: false,
            promotions: false,
          },
        },
        cards,
      }),
    ];

    const result = await simulateSendExpirationAlerts(NOW);

    expect(result.alertCount).toBe(0);
    expect(createdNotifications).toHaveLength(0);
  });

  test("finds cards expiring within 30 days", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-expiring-soon", {
      expirationDate: daysFromNow(15, NOW),
      retailer: "Target",
      balance: 25,
    });
    cards.set("card-far-away", {
      expirationDate: daysFromNow(60, NOW),
      retailer: "Walmart",
      balance: 100,
    });

    mockUsers = [
      createMockUser({
        uid: "user-1",
        cards,
      }),
    ];

    const result = await simulateSendExpirationAlerts(NOW);

    expect(result.alertCount).toBe(1);
    expect(createdNotifications).toHaveLength(1);
    expect(createdNotifications[0].data.cardId).toBe("card-expiring-soon");
  });

  test("creates notification with correct days-remaining count", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-10d", {
      expirationDate: daysFromNow(10, NOW),
      retailer: "Starbucks",
      balance: 15,
    });

    mockUsers = [
      createMockUser({
        uid: "user-2",
        cards,
      }),
    ];

    await simulateSendExpirationAlerts(NOW);

    expect(createdNotifications).toHaveLength(1);
    const notification = createdNotifications[0].data;
    expect(notification.body).toBe(
      "Your Starbucks card ($15) expires in 10 days."
    );
    expect(notification.type).toBe("expiration_alert");
    expect(notification.title).toBe("Card Expiring Soon");
    expect(notification.isRead).toBe(false);
  });

  test("singular 'day' when exactly 1 day remains", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-1d", {
      expirationDate: daysFromNow(1, NOW),
      retailer: "iTunes",
      balance: 5,
    });

    mockUsers = [
      createMockUser({
        uid: "user-singular",
        cards,
      }),
    ];

    await simulateSendExpirationAlerts(NOW);

    expect(createdNotifications).toHaveLength(1);
    expect(createdNotifications[0].data.body).toBe(
      "Your iTunes card ($5) expires in 1 day."
    );
  });

  test("deduplicates - skips if alert sent within 7 days", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-dup", {
      expirationDate: daysFromNow(20, NOW),
      retailer: "BestBuy",
      balance: 75,
    });

    // Simulate that an alert was already sent 3 days ago
    const threeDaysAgo = new Date(NOW.getTime() - 3 * 24 * 60 * 60 * 1000);

    mockUsers = [
      createMockUser({
        uid: "user-dedup",
        cards,
        notifications: [
          {
            type: "expiration_alert",
            cardId: "card-dup",
            createdAt: threeDaysAgo,
          },
        ],
      }),
    ];

    const result = await simulateSendExpirationAlerts(NOW);

    expect(result.alertCount).toBe(0);
    expect(createdNotifications).toHaveLength(0);
  });

  test("does not deduplicate if alert was sent more than 7 days ago", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-old-alert", {
      expirationDate: daysFromNow(20, NOW),
      retailer: "Target",
      balance: 30,
    });

    // Alert was sent 10 days ago -- older than 7-day window
    const tenDaysAgo = new Date(NOW.getTime() - 10 * 24 * 60 * 60 * 1000);

    mockUsers = [
      createMockUser({
        uid: "user-old-dedup",
        cards,
        notifications: [
          {
            type: "expiration_alert",
            cardId: "card-old-alert",
            createdAt: tenDaysAgo,
          },
        ],
      }),
    ];

    const result = await simulateSendExpirationAlerts(NOW);

    expect(result.alertCount).toBe(1);
    expect(createdNotifications).toHaveLength(1);
  });

  test("does not create notification for non-expiring cards", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-far", {
      expirationDate: daysFromNow(90, NOW),
      retailer: "Amazon",
      balance: 200,
    });

    mockUsers = [
      createMockUser({
        uid: "user-no-expire",
        cards,
      }),
    ];

    const result = await simulateSendExpirationAlerts(NOW);

    expect(result.alertCount).toBe(0);
    expect(createdNotifications).toHaveLength(0);
  });

  test("does not create notification for already-expired cards", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-expired", {
      expirationDate: daysFromNow(-5, NOW),
      retailer: "Nike",
      balance: 10,
    });

    mockUsers = [
      createMockUser({
        uid: "user-expired",
        cards,
      }),
    ];

    const result = await simulateSendExpirationAlerts(NOW);

    expect(result.alertCount).toBe(0);
    expect(createdNotifications).toHaveLength(0);
  });

  test("sends FCM push to users with tokens", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-push", {
      expirationDate: daysFromNow(5, NOW),
      retailer: "Uber",
      balance: 20,
    });

    mockUsers = [
      createMockUser({
        uid: "user-with-token",
        data: {
          fcmToken: "fcm-token-abc",
          notificationPreferences: {
            push: true,
            email: true,
            expirationAlerts: true,
            promotions: false,
          },
        },
        cards,
      }),
    ];

    await simulateSendExpirationAlerts(NOW);

    expect(sentMessages).toHaveLength(1);
    expect(sentMessages[0]).toEqual(
      expect.objectContaining({
        token: "fcm-token-abc",
        notification: expect.objectContaining({
          title: "Cards Expiring Soon",
          body: "You have 1 card expiring within 30 days.",
        }),
        data: expect.objectContaining({
          type: "expiration_alert",
          cardCount: "1",
        }),
      })
    );
  });

  test("does not send FCM push to users without tokens", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-no-push", {
      expirationDate: daysFromNow(5, NOW),
      retailer: "Lyft",
      balance: 30,
    });

    mockUsers = [
      createMockUser({
        uid: "user-no-token",
        data: {
          notificationPreferences: {
            push: true,
            email: true,
            expirationAlerts: true,
            promotions: false,
          },
        },
        cards,
      }),
    ];

    await simulateSendExpirationAlerts(NOW);

    expect(createdNotifications).toHaveLength(1);
    expect(sentMessages).toHaveLength(0);
  });

  test("FCM push body pluralizes for multiple expiring cards", async () => {
    const cards = new Map<string, MockCard>();
    cards.set("card-a", {
      expirationDate: daysFromNow(5, NOW),
      retailer: "Store A",
      balance: 10,
    });
    cards.set("card-b", {
      expirationDate: daysFromNow(15, NOW),
      retailer: "Store B",
      balance: 20,
    });

    mockUsers = [
      createMockUser({
        uid: "user-multi",
        data: {
          pushToken: "push-token-multi",
          notificationPreferences: {
            push: true,
            email: true,
            expirationAlerts: true,
            promotions: false,
          },
        },
        cards,
      }),
    ];

    await simulateSendExpirationAlerts(NOW);

    expect(createdNotifications).toHaveLength(2);
    expect(sentMessages).toHaveLength(1);
    expect(sentMessages[0].notification).toEqual(
      expect.objectContaining({
        body: "You have 2 cards expiring within 30 days.",
      })
    );
    expect((sentMessages[0].data as Record<string, string>).cardCount).toBe("2");
  });

  test("processes multiple users independently", async () => {
    const cardsUserA = new Map<string, MockCard>();
    cardsUserA.set("card-ua", {
      expirationDate: daysFromNow(7, NOW),
      retailer: "Apple",
      balance: 50,
    });

    const cardsUserB = new Map<string, MockCard>();
    cardsUserB.set("card-ub", {
      expirationDate: daysFromNow(25, NOW),
      retailer: "Google",
      balance: 25,
    });

    mockUsers = [
      createMockUser({ uid: "user-a", cards: cardsUserA }),
      createMockUser({ uid: "user-b", cards: cardsUserB }),
    ];

    const result = await simulateSendExpirationAlerts(NOW);

    expect(result.alertCount).toBe(2);
    expect(createdNotifications).toHaveLength(2);

    const uids = createdNotifications.map((n) => n.uid);
    expect(uids).toContain("user-a");
    expect(uids).toContain("user-b");
  });
});
