import * as functions from "firebase-functions";
import { db } from "../utils/admin";
import * as admin from "firebase-admin";

/**
 * Firestore trigger: when a new user is created in Firebase Auth,
 * provision a default user document in /users/{uid}.
 */
export const onUserCreate = functions.auth.user().onCreate(async (user) => {
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
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),

    // Metrics
    loginCount: 0,

    // Status
    isSuspended: false,
  };

  await db.doc(`users/${uid}`).set(userDoc);

  functions.logger.info("Created default user document", { uid, email });
});
