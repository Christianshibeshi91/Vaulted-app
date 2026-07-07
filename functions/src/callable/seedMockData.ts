import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { db, isAdmin, writeAuditLog } from "../utils/admin";

// ─── Realistic seed data pools ───────────────────────────────────

const FIRST_NAMES = [
  "James", "Maria", "David", "Sarah", "Michael",
  "Emily", "Robert", "Jessica", "William", "Ashley",
];

const LAST_NAMES = [
  "Smith", "Johnson", "Williams", "Brown", "Jones",
  "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
];

const RETAILERS = [
  "Amazon", "Target", "Walmart", "Starbucks", "Apple",
  "Nike", "Sephora", "Best Buy", "Home Depot", "Nordstrom",
  "Costco", "Uber", "DoorDash", "Netflix", "Spotify",
  "Chipotle", "Whole Foods", "Lululemon", "REI", "GameStop",
];

const RETAILER_CATEGORIES: Record<string, string> = {
  Amazon: "shopping", Target: "shopping", Walmart: "shopping",
  Starbucks: "food_drink", Apple: "technology", Nike: "fashion",
  Sephora: "beauty", "Best Buy": "technology", "Home Depot": "home",
  Nordstrom: "fashion", Costco: "shopping", Uber: "transport",
  DoorDash: "food_drink", Netflix: "entertainment", Spotify: "entertainment",
  Chipotle: "food_drink", "Whole Foods": "grocery", Lululemon: "fashion",
  REI: "outdoors", GameStop: "entertainment",
};

const NOTIFICATION_TYPES = [
  "expiration_alert", "balance_update", "promotion",
  "security_alert", "system_update",
];

const PLANS = ["free", "free", "free", "free", "premium", "premium", "pro"];

// ─── Helpers ─────────────────────────────────────────────────────

function randomInt(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomElement<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function randomDate(daysBack: number): Date {
  const now = Date.now();
  return new Date(now - Math.random() * daysBack * 24 * 60 * 60 * 1000);
}

function futureDate(daysAhead: number): Date {
  const now = Date.now();
  return new Date(now + Math.random() * daysAhead * 24 * 60 * 60 * 1000);
}

function generateEmail(first: string, last: string): string {
  const domains = ["gmail.com", "outlook.com", "yahoo.com", "icloud.com"];
  const suffix = randomInt(10, 99);
  return `${first.toLowerCase()}.${last.toLowerCase()}${suffix}@${randomElement(domains)}`;
}

// ─── Callable ────────────────────────────────────────────────────

/**
 * Admin-only callable: seed the Firestore database with realistic mock data.
 *
 * Generates:
 * - 10 users with profiles
 * - 40-60 cards across 20 retailers
 * - 150+ transactions
 * - 30+ notifications
 * - Feature flags, app settings, alerts, audit entries
 * - 30 days of stats history
 */
export const seedMockData = functions.https.onCall(async (_data, context) => {
  // ── Environment gate: block in production ────────────────────────
  if (!process.env.FUNCTIONS_EMULATOR) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "seedMockData is only available in the emulator environment."
    );
  }

  // ── Auth gate ──────────────────────────────────────────────────
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required."
    );
  }
  if (!(await isAdmin(context.auth.uid))) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins can seed mock data."
    );
  }

  const batch = db.batch();
  const userIds: string[] = [];

  // ── 1. Create 10 users ────────────────────────────────────────
  for (let i = 0; i < 10; i++) {
    const first = FIRST_NAMES[i];
    const last = LAST_NAMES[i];
    const uid = `mock_user_${String(i + 1).padStart(3, "0")}`;
    userIds.push(uid);

    const plan = randomElement(PLANS);
    const createdAt = randomDate(90);

    batch.set(db.doc(`users/${uid}`), {
      email: generateEmail(first, last),
      displayName: `${first} ${last}`,
      role: "user",
      plan,
      mfaEnabled: Math.random() > 0.7,
      biometricEnabled: Math.random() > 0.5,
      onboardingComplete: true,
      notificationPreferences: {
        push: true,
        email: Math.random() > 0.3,
        expirationAlerts: true,
        promotions: Math.random() > 0.5,
      },
      createdAt: admin.firestore.Timestamp.fromDate(createdAt),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLoginAt: admin.firestore.Timestamp.fromDate(randomDate(7)),
      loginCount: randomInt(5, 200),
      isSuspended: false,
    });
  }

  await batch.commit();

  // ── 2. Create 40-60 cards across retailers ────────────────────
  const totalCards = randomInt(40, 60);
  let cardBatch = db.batch();
  let cardBatchCount = 0;
  const cardRefs: { uid: string; cardId: string; retailer: string }[] = [];

  for (let i = 0; i < totalCards; i++) {
    const uid = randomElement(userIds);
    const retailer = RETAILERS[i % RETAILERS.length];
    const cardRef = db.collection(`users/${uid}/cards`).doc();

    const originalBalance = randomInt(10, 500);
    const balance = Math.round(
      originalBalance * (0.3 + Math.random() * 0.7) * 100
    ) / 100;

    cardBatch.set(cardRef, {
      retailer: retailer,
      category: RETAILER_CATEGORIES[retailer] ?? "other",
      originalBalance,
      balance,
      cardNumber: `XXXX-XXXX-${String(randomInt(1000, 9999))}`,
      pin: String(randomInt(1000, 9999)),
      barcode: `VAULT${String(randomInt(100000000, 999999999))}`,
      expirationDate: admin.firestore.Timestamp.fromDate(
        futureDate(randomInt(30, 730))
      ),
      isArchived: Math.random() > 0.9,
      isFavorite: Math.random() > 0.7,
      notes: Math.random() > 0.6 ? "Birthday gift" : "",
      addedAt: admin.firestore.Timestamp.fromDate(randomDate(60)),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    cardRefs.push({ uid, cardId: cardRef.id, retailer });
    cardBatchCount++;

    // Firestore batch limit is 500 writes
    if (cardBatchCount >= 450) {
      await cardBatch.commit();
      cardBatch = db.batch();
      cardBatchCount = 0;
    }
  }

  if (cardBatchCount > 0) await cardBatch.commit();

  // ── 3. Create 150+ transactions ──────────────────────────────
  let txBatch = db.batch();
  let txBatchCount = 0;
  const transactionTypes = ["purchase", "refund", "transfer", "redemption"];
  const statuses = [
    "completed", "completed", "completed", "completed",
    "pending", "flagged",
  ];

  for (let i = 0; i < 160; i++) {
    const card = randomElement(cardRefs);
    const txRef = db.collection(`users/${card.uid}/transactions`).doc();

    txBatch.set(txRef, {
      cardId: card.cardId,
      retailer: card.retailer,
      type: randomElement(transactionTypes),
      amount: Math.round((Math.random() * 100 + 1) * 100) / 100,
      status: randomElement(statuses),
      description: `Transaction at ${card.retailer}`,
      createdAt: admin.firestore.Timestamp.fromDate(randomDate(30)),
    });

    txBatchCount++;
    if (txBatchCount >= 450) {
      await txBatch.commit();
      txBatch = db.batch();
      txBatchCount = 0;
    }
  }

  if (txBatchCount > 0) await txBatch.commit();

  // ── 4. Create 30+ notifications ──────────────────────────────
  const notifBatch = db.batch();

  for (let i = 0; i < 35; i++) {
    const uid = randomElement(userIds);
    const type = randomElement(NOTIFICATION_TYPES);
    const ref = db.collection(`users/${uid}/notifications`).doc();

    notifBatch.set(ref, {
      type,
      title: `${type.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase())}`,
      body: `Notification body for ${type}`,
      isRead: Math.random() > 0.5,
      createdAt: admin.firestore.Timestamp.fromDate(randomDate(14)),
    });
  }

  await notifBatch.commit();

  // ── 5. Feature flags ─────────────────────────────────────────
  await db.doc("admin/featureFlags").set({
    darkMode: true,
    biometricAuth: true,
    cardScanner: false,
    socialSharing: false,
    premiumTier: true,
    aiCategorization: false,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // ── 6. App settings ──────────────────────────────────────────
  await db.doc("admin/appSettings").set({
    maintenanceMode: false,
    minimumAppVersion: "1.0.0",
    maxCardsPerUser: 50,
    maxCardValueLimit: 2000,
    supportEmail: "support@vaulted.app",
    termsVersion: "1.0",
    privacyVersion: "1.0",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // ── 7. Admin alerts ──────────────────────────────────────────
  const alertsBatch = db.batch();
  const alertTypes = ["security", "system", "user_report", "fraud"];

  for (let i = 0; i < 8; i++) {
    const ref = db.collection("admin/alerts/items").doc();
    alertsBatch.set(ref, {
      type: randomElement(alertTypes),
      severity: randomElement(["low", "medium", "high", "critical"]),
      title: `Alert #${i + 1}`,
      message: `Sample alert message ${i + 1}`,
      isResolved: Math.random() > 0.5,
      createdAt: admin.firestore.Timestamp.fromDate(randomDate(7)),
    });
  }
  await alertsBatch.commit();

  // ── 8. Audit entries ──────────────────────────────────────────
  const auditBatch = db.batch();
  const auditActions = [
    "USER_LOGIN", "CARD_ADDED", "CARD_DELETED", "SETTINGS_CHANGED",
    "ADMIN_ACCESS", "DATA_EXPORT", "USER_SUSPENDED",
  ];

  for (let i = 0; i < 15; i++) {
    const ref = db.collection("admin/auditLog/entries").doc();
    auditBatch.set(ref, {
      action: randomElement(auditActions),
      performedBy: randomElement(userIds),
      targetUid: Math.random() > 0.5 ? randomElement(userIds) : null,
      details: { note: `Seeded audit entry ${i + 1}` },
      timestamp: admin.firestore.Timestamp.fromDate(randomDate(30)),
    });
  }
  await auditBatch.commit();

  // ── 9. 30 days of stats history ───────────────────────────────
  const statsBatch = db.batch();

  for (let d = 0; d < 30; d++) {
    const date = new Date();
    date.setDate(date.getDate() - d);
    const dateKey = date.toISOString().split("T")[0];

    statsBatch.set(db.doc(`admin/stats/daily/${dateKey}`), {
      totalUsers: randomInt(50, 200) + d * 2,
      newUsers: randomInt(0, 10),
      premiumUsers: randomInt(5, 40),
      totalCards: randomInt(100, 500),
      totalCardValue: Math.round(randomInt(5000, 50000) * 100) / 100,
      calculatedAt: admin.firestore.Timestamp.fromDate(date),
    });
  }
  await statsBatch.commit();

  // ── Audit the seed itself ─────────────────────────────────────
  await writeAuditLog({
    action: "SEED_MOCK_DATA",
    performedBy: context.auth.uid,
    details: {
      users: 10,
      cards: totalCards,
      transactions: 160,
      notifications: 35,
    },
  });

  functions.logger.info("Mock data seeded", {
    users: 10,
    cards: totalCards,
    transactions: 160,
  });

  return {
    success: true,
    seeded: {
      users: 10,
      cards: totalCards,
      transactions: 160,
      notifications: 35,
      statsHistory: 30,
    },
  };
});
