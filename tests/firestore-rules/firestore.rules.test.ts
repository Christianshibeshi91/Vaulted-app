/**
 * Firestore Security Rules Unit Tests
 *
 * These tests verify the Firestore rules logic by simulating the rule
 * conditions. In a CI environment you would use @firebase/rules-unit-testing
 * with the Firebase emulator. Here we test the logical conditions as pure
 * functions to validate the security model without requiring the emulator.
 */

// ── Rule simulation helpers ──────────────────────────────────────────

interface AuthContext {
  uid: string;
  token?: { admin?: boolean };
}

interface RuleRequest {
  auth: AuthContext | null;
  resource?: { data: Record<string, unknown> };
}

// Simulates: isAuthenticated()
function isAuthenticated(request: RuleRequest): boolean {
  return request.auth != null;
}

// Simulates: isOwner(userId)
function isOwner(request: RuleRequest, userId: string): boolean {
  return isAuthenticated(request) && request.auth!.uid === userId;
}

// Simulates: isAdmin()
function isAdmin(request: RuleRequest): boolean {
  return isAuthenticated(request) && request.auth?.token?.admin === true;
}

// Simulates: roleNotChanged()
function roleNotChanged(
  requestData: Record<string, unknown>,
  existingData: Record<string, unknown>
): boolean {
  if (!("role" in requestData)) return true;
  return requestData.role === existingData.role;
}

// Simulates: validUserData()
function validUserData(data: Record<string, unknown>): boolean {
  return (
    typeof data.email === "string" &&
    (data.email as string).length > 0 &&
    (data.email as string).length <= 320 &&
    typeof data.role === "string" &&
    ["user", "admin"].includes(data.role as string) &&
    typeof data.plan === "string" &&
    ["free", "premium"].includes(data.plan as string) &&
    typeof data.mfaEnabled === "boolean" &&
    typeof data.biometricEnabled === "boolean"
  );
}

// Simulates: validCardData()
function validCardData(data: Record<string, unknown>): boolean {
  return (
    typeof data.retailer === "string" &&
    (data.retailer as string).length > 0 &&
    (data.retailer as string).length <= 100 &&
    typeof data.balance === "number" &&
    (data.balance as number) >= 0 &&
    typeof data.originalBalance === "number" &&
    (data.originalBalance as number) >= 0 &&
    typeof data.status === "string" &&
    ["active", "depleted", "expired", "archived"].includes(data.status as string)
  );
}

// Simulates: validTransactionData()
function validTransactionData(data: Record<string, unknown>): boolean {
  return (
    typeof data.cardId === "string" &&
    typeof data.retailer === "string" &&
    typeof data.type === "string" &&
    ["purchase", "refund", "balance_check", "adjustment", "transfer"].includes(
      data.type as string
    ) &&
    typeof data.amount === "number" &&
    typeof data.balanceAfter === "number" &&
    (data.balanceAfter as number) >= 0
  );
}

// ── User document access rules ────────────────────────────────────────

function canReadUser(request: RuleRequest, userId: string): boolean {
  return isOwner(request, userId) || isAdmin(request);
}

function canCreateUser(
  request: RuleRequest,
  userId: string,
  data: Record<string, unknown>
): boolean {
  return (
    (isOwner(request, userId) &&
      data.role === "user" &&
      validUserData(data)) ||
    isAdmin(request)
  );
}

function canUpdateUser(
  request: RuleRequest,
  userId: string,
  newData: Record<string, unknown>,
  existingData: Record<string, unknown>
): boolean {
  return (
    (isOwner(request, userId) &&
      roleNotChanged(newData, existingData) &&
      validUserData(newData)) ||
    isAdmin(request)
  );
}

function canDeleteUser(request: RuleRequest): boolean {
  return isAdmin(request);
}

// ── Card subcollection access rules ───────────────────────────────────

function canReadCard(request: RuleRequest, userId: string): boolean {
  return isOwner(request, userId) || isAdmin(request);
}

function canCreateCard(
  request: RuleRequest,
  userId: string,
  data: Record<string, unknown>
): boolean {
  return (isOwner(request, userId) && validCardData(data)) || isAdmin(request);
}

// ── Notification subcollection access rules ───────────────────────────

function canUpdateNotification(
  request: RuleRequest,
  userId: string,
  affectedKeys: string[]
): boolean {
  if (!isOwner(request, userId)) return false;
  // Owner can only update "isRead" field
  return affectedKeys.every((key) => key === "isRead");
}

// ── Tests ──────────────────────────────────────────────────────────────

describe("Firestore Security Rules", () => {
  const regularUser: AuthContext = { uid: "user-1" };
  const adminUser: AuthContext = { uid: "admin-1", token: { admin: true } };
  const otherUser: AuthContext = { uid: "user-2" };

  // ── Authentication ──────────────────────────────────────────────

  describe("Authentication", () => {
    test("unauthenticated requests are denied", () => {
      expect(isAuthenticated({ auth: null })).toBe(false);
    });

    test("authenticated requests pass", () => {
      expect(isAuthenticated({ auth: regularUser })).toBe(true);
    });
  });

  // ── User documents ─────────────────────────────────────────────

  describe("User documents", () => {
    test("owner can read their own user document", () => {
      expect(canReadUser({ auth: regularUser }, "user-1")).toBe(true);
    });

    test("admin can read any user document", () => {
      expect(canReadUser({ auth: adminUser }, "user-1")).toBe(true);
    });

    test("other users cannot read someone else's document", () => {
      expect(canReadUser({ auth: otherUser }, "user-1")).toBe(false);
    });

    test("unauthenticated cannot read user documents", () => {
      expect(canReadUser({ auth: null }, "user-1")).toBe(false);
    });

    test("owner can create their own document with valid data", () => {
      const data = {
        email: "test@example.com",
        role: "user",
        plan: "free",
        mfaEnabled: false,
        biometricEnabled: false,
      };
      expect(canCreateUser({ auth: regularUser }, "user-1", data)).toBe(true);
    });

    test("owner cannot create document with invalid role", () => {
      const data = {
        email: "test@example.com",
        role: "superadmin",
        plan: "free",
        mfaEnabled: false,
        biometricEnabled: false,
      };
      expect(canCreateUser({ auth: regularUser }, "user-1", data)).toBe(false);
    });

    test("owner cannot create document with admin role", () => {
      const data = {
        email: "test@example.com",
        role: "admin",
        plan: "free",
        mfaEnabled: false,
        biometricEnabled: false,
      };
      expect(canCreateUser({ auth: regularUser }, "user-1", data)).toBe(false);
    });

    test("owner cannot create document with empty email", () => {
      const data = {
        email: "",
        role: "user",
        plan: "free",
        mfaEnabled: false,
        biometricEnabled: false,
      };
      expect(canCreateUser({ auth: regularUser }, "user-1", data)).toBe(false);
    });

    test("owner cannot escalate their role", () => {
      const existingData = { role: "user" };
      const newData = {
        email: "test@example.com",
        role: "admin",
        plan: "free",
        mfaEnabled: false,
        biometricEnabled: false,
      };
      expect(
        canUpdateUser({ auth: regularUser }, "user-1", newData, existingData)
      ).toBe(false);
    });

    test("owner can update non-role fields", () => {
      const existingData = { role: "user" };
      const newData = {
        email: "new@example.com",
        role: "user",
        plan: "premium",
        mfaEnabled: true,
        biometricEnabled: false,
      };
      expect(
        canUpdateUser({ auth: regularUser }, "user-1", newData, existingData)
      ).toBe(true);
    });

    test("admin can update any user's role", () => {
      const existingData = { role: "user" };
      const newData = {
        email: "test@example.com",
        role: "admin",
        plan: "free",
        mfaEnabled: false,
        biometricEnabled: false,
      };
      expect(
        canUpdateUser({ auth: adminUser }, "user-1", newData, existingData)
      ).toBe(true);
    });

    test("only admin can delete user documents", () => {
      expect(canDeleteUser({ auth: adminUser })).toBe(true);
      expect(canDeleteUser({ auth: { auth: regularUser } as any })).toBe(false);
    });

    test("unauthenticated cannot delete user documents", () => {
      expect(canDeleteUser({ auth: null })).toBe(false);
    });
  });

  // ── Cards subcollection ────────────────────────────────────────

  describe("Cards subcollection", () => {
    test("owner can read their own cards", () => {
      expect(canReadCard({ auth: regularUser }, "user-1")).toBe(true);
    });

    test("other users cannot read cards", () => {
      expect(canReadCard({ auth: otherUser }, "user-1")).toBe(false);
    });

    test("admin can read any user's cards", () => {
      expect(canReadCard({ auth: adminUser }, "user-1")).toBe(true);
    });

    test("owner can create card with valid data", () => {
      const data = {
        retailer: "Amazon",
        balance: 50.0,
        originalBalance: 50.0,
        status: "active",
      };
      expect(canCreateCard({ auth: regularUser }, "user-1", data)).toBe(true);
    });

    test("rejects card with negative balance", () => {
      const data = {
        retailer: "Amazon",
        balance: -10.0,
        originalBalance: 50.0,
        status: "active",
      };
      expect(canCreateCard({ auth: regularUser }, "user-1", data)).toBe(false);
    });

    test("rejects card with invalid status", () => {
      const data = {
        retailer: "Amazon",
        balance: 50.0,
        originalBalance: 50.0,
        status: "invalid",
      };
      expect(canCreateCard({ auth: regularUser }, "user-1", data)).toBe(false);
    });

    test("rejects card with empty retailer name", () => {
      const data = {
        retailer: "",
        balance: 50.0,
        originalBalance: 50.0,
        status: "active",
      };
      expect(canCreateCard({ auth: regularUser }, "user-1", data)).toBe(false);
    });

    test("rejects card with retailer name exceeding 100 chars", () => {
      const data = {
        retailer: "A".repeat(101),
        balance: 50.0,
        originalBalance: 50.0,
        status: "active",
      };
      expect(canCreateCard({ auth: regularUser }, "user-1", data)).toBe(false);
    });
  });

  // ── Transactions subcollection ─────────────────────────────────

  describe("Transactions subcollection", () => {
    test("valid transaction data passes validation", () => {
      const data = {
        cardId: "card-1",
        retailer: "Amazon",
        type: "purchase",
        amount: 25.0,
        balanceAfter: 75.0,
      };
      expect(validTransactionData(data)).toBe(true);
    });

    test("rejects invalid transaction type", () => {
      const data = {
        cardId: "card-1",
        retailer: "Amazon",
        type: "theft",
        amount: 25.0,
        balanceAfter: 75.0,
      };
      expect(validTransactionData(data)).toBe(false);
    });

    test("rejects negative balanceAfter", () => {
      const data = {
        cardId: "card-1",
        retailer: "Amazon",
        type: "purchase",
        amount: 25.0,
        balanceAfter: -5.0,
      };
      expect(validTransactionData(data)).toBe(false);
    });

    test("rejects missing cardId", () => {
      const data = {
        retailer: "Amazon",
        type: "purchase",
        amount: 25.0,
        balanceAfter: 75.0,
      };
      expect(validTransactionData(data as any)).toBe(false);
    });

    test("allows all valid transaction types", () => {
      const types = ["purchase", "refund", "balance_check", "adjustment", "transfer"];
      for (const type of types) {
        expect(
          validTransactionData({
            cardId: "c1",
            retailer: "R",
            type,
            amount: 1.0,
            balanceAfter: 0,
          })
        ).toBe(true);
      }
    });
  });

  // ── Notifications subcollection ────────────────────────────────

  describe("Notifications subcollection", () => {
    test("owner can update only isRead field", () => {
      expect(
        canUpdateNotification({ auth: regularUser }, "user-1", ["isRead"])
      ).toBe(true);
    });

    test("owner cannot update other fields", () => {
      expect(
        canUpdateNotification({ auth: regularUser }, "user-1", [
          "isRead",
          "title",
        ])
      ).toBe(false);
    });

    test("owner cannot update only non-isRead fields", () => {
      expect(
        canUpdateNotification({ auth: regularUser }, "user-1", ["body"])
      ).toBe(false);
    });

    test("other user cannot update notifications", () => {
      expect(
        canUpdateNotification({ auth: otherUser }, "user-1", ["isRead"])
      ).toBe(false);
    });
  });

  // ── Admin collection ───────────────────────────────────────────

  describe("Admin collection", () => {
    test("admin can read admin collection", () => {
      expect(isAdmin({ auth: adminUser })).toBe(true);
    });

    test("regular user cannot access admin collection", () => {
      expect(isAdmin({ auth: { uid: "user-1" } })).toBe(false);
    });

    test("unauthenticated cannot access admin collection", () => {
      expect(isAdmin({ auth: null })).toBe(false);
    });
  });

  // ── Plan validation ────────────────────────────────────────────

  describe("Plan field validation", () => {
    test("accepts free plan", () => {
      const data = {
        email: "a@b.com",
        role: "user",
        plan: "free",
        mfaEnabled: false,
        biometricEnabled: false,
      };
      expect(validUserData(data)).toBe(true);
    });

    test("accepts premium plan", () => {
      const data = {
        email: "a@b.com",
        role: "user",
        plan: "premium",
        mfaEnabled: false,
        biometricEnabled: false,
      };
      expect(validUserData(data)).toBe(true);
    });

    test("rejects invalid plan", () => {
      const data = {
        email: "a@b.com",
        role: "user",
        plan: "enterprise",
        mfaEnabled: false,
        biometricEnabled: false,
      };
      expect(validUserData(data)).toBe(false);
    });
  });
});
