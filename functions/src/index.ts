// ─── Auth triggers ───────────────────────────────────────────────
export { onUserCreate } from "./auth/onUserCreate";
export { setAdminClaim } from "./auth/setAdminClaim";

// ─── Scheduled functions ─────────────────────────────────────────
export { sendExpirationAlerts } from "./scheduled/sendExpirationAlerts";
export { calculateDailyStats } from "./scheduled/calculateDailyStats";
export { configHealthCheck } from "./scheduled/configHealthCheck";

// ─── Callable functions ──────────────────────────────────────────
export { seedMockData } from "./callable/seedMockData";
export { deleteUserCascade } from "./callable/deleteUserCascade";
export { exportUserData } from "./callable/exportUserData";
export { broadcastNotification } from "./callable/broadcastNotification";

// ─── Firestore triggers ─────────────────────────────────────────
export { onTransactionFlagged } from "./triggers/onTransactionFlagged";
export { onBalanceCheckLogged } from "./triggers/onBalanceCheckLogged";
