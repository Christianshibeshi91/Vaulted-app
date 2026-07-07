'use strict';

/**
 * Seed an admin user into the vaulted-app-c89d2 Firebase project.
 * Usage: node scripts/seed-admin.js
 *
 * Uses Application Default Credentials from Firebase CLI login.
 */

const admin = require('firebase-admin');

const ADMIN_EMAIL = 'admin@vaulted.app';
const ADMIN_PASSWORD = 'Admin!23';
const ADMIN_NAME = 'Admin';
const PROJECT_ID = 'vaulted-app-c89d2';

async function seed() {
  // Initialize using Application Default Credentials (from `firebase login`)
  if (!admin.apps.length) {
    admin.initializeApp({
      projectId: PROJECT_ID,
    });
  }

  const db = admin.firestore();
  console.log(`Connected to Firebase project: ${PROJECT_ID}`);

  // Create or retrieve Firebase Auth user
  let userId;
  try {
    const authUser = await admin.auth().getUserByEmail(ADMIN_EMAIL);
    userId = authUser.uid;
    console.log(`Firebase Auth user exists: ${userId}`);
    // Update password in case it changed
    await admin.auth().updateUser(userId, { password: ADMIN_PASSWORD });
    console.log('Password updated.');
  } catch (err) {
    if (err.code === 'auth/user-not-found') {
      const authUser = await admin.auth().createUser({
        email: ADMIN_EMAIL,
        password: ADMIN_PASSWORD,
        displayName: ADMIN_NAME,
      });
      userId = authUser.uid;
      console.log(`Created Firebase Auth user: ${userId}`);
    } else {
      throw err;
    }
  }

  // Set custom claims for admin access
  await admin.auth().setCustomUserClaims(userId, { admin: true });
  console.log('Firebase custom claims set: { admin: true }');

  // Create/update Firestore document (Flutter UserModel schema)
  const now = new Date();
  await db.collection('users').doc(userId).set({
    email: ADMIN_EMAIL,
    displayName: ADMIN_NAME,
    role: 'admin',
    plan: 'premium',
    onboardingComplete: true,
    mfaEnabled: false,
    biometricEnabled: false,
    isSuspended: false,
    autoLockMinutes: 5,
    notificationPreferences: { email: true, push: false },
    loginCount: 0,
    createdAt: now,
    updatedAt: now,
  }, { merge: true });

  console.log('Admin user seeded successfully!');
  console.log(`  Email:    ${ADMIN_EMAIL}`);
  console.log(`  Password: ${ADMIN_PASSWORD}`);
  console.log(`  Project:  ${PROJECT_ID}`);
  console.log(`  Role:     admin (custom claim + Firestore)`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed failed:', err.message || err);
  process.exit(1);
});
