# Vaulted App -- Comprehensive Plan

**Date:** 2026-03-21
**Project:** Vaulted -- Dark Luxury Fintech Gift Card Wallet
**Stack:** Flutter 3.11+ / Dart, Firebase (Auth, Firestore, Storage, Functions, Hosting), Riverpod, GoRouter
**Architecture:** Clean Architecture (core / data / domain / presentation)
**Production URL:** https://web-one-taupe-85.vercel.app
**Firebase Project:** vaulted-app-c89d2

---

## 1. Overview

Vaulted is a cross-platform gift card wallet with AES-256 encryption at rest, admin dashboards, real-time Firestore sync, and a dark luxury UI. T001-T008 are complete (build/fix phase). The app is deployed to Vercel with 246/246 Flutter tests and 40/40 Playwright E2E tests passing, zero analysis warnings.

This plan covers everything remaining: deployment completion, security hardening, missing features, performance optimization, code quality improvements, and test coverage gaps.

---

## 2. Project Type

**MOBILE** (Flutter cross-platform: Web, Android, iOS)

Primary agent: mobile-developer
Supporting agents: security-auditor, performance-optimizer, test-engineer

---

## 3. Success Criteria

| Criterion | Measurement |
|-----------|-------------|
| Firebase fully deployed | Firestore rules, Storage rules, indexes, all 9 Cloud Functions live |
| Auth flow works end-to-end | Email/password + Google + Apple Sign-In functional on production |
| Zero critical security findings | No OWASP Top 10 violations, no hardcoded secrets, no open admin endpoints |
| All TODOs resolved or tracked | 15 TODO stubs either implemented or converted to backlog items |
| Test coverage above 80 percent | Provider, screen, and integration tests cover all critical paths |
| Performance budget met | LCP under 3s, FCP under 1.5s, bundle size under 5MB (web) |
| Clean codebase | Zero analysis warnings, consistent patterns, no dead code |

---

## 4. Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Framework | Flutter 3.11+ / Dart | Cross-platform (web, iOS, Android) from single codebase |
| Backend | Firebase (Auth, Firestore, Storage, Functions) | Serverless, real-time sync, integrated auth |
| State | Riverpod 2.6 + Freezed | Type-safe, testable, code-gen models |
| Navigation | GoRouter 14.8 | Declarative routing with auth redirects |
| Encryption | AES-256-CBC via encrypt package | Card numbers and PINs encrypted at rest |
| Secure Storage | flutter_secure_storage | Keychain (iOS) / EncryptedSharedPrefs (Android) |
| Testing | Flutter test + Playwright | Unit/widget tests + E2E browser tests |
| Deploy (web) | Vercel + Firebase Hosting | Dual deployment for CDN + Firebase integration |


---

## 5. Current Codebase Map



---

## 6. Task Breakdown

### PHASE 1: DEPLOYMENT COMPLETION (P0 -- Blockers)

#### T009: Deploy Firebase Rules, Indexes, and Cloud Functions
- **Agent:** mobile-developer
- **Priority:** P0
- **Dependencies:** None (Firebase CLI auth required from user)
- **Status:** IN_PROGRESS
- **INPUT:** firestore.rules, storage.rules, firestore.indexes.json, functions/src/*.ts
- **OUTPUT:** All resources deployed to vaulted-app-c89d2
- **VERIFY:**
  - firebase deploy --only firestore,storage,functions exits 0
  - Firebase Console shows 9 functions deployed
  - Firestore Rules playground rejects unauthorized writes

#### T010: Deploy Flutter Web to Firebase Hosting
- **Agent:** mobile-developer
- **Priority:** P0
- **Dependencies:** T009
- **INPUT:** build/web/ (pre-built), firebase.json hosting config
- **OUTPUT:** App accessible at https://vaulted-app-c89d2.web.app
- **VERIFY:**
  - firebase deploy --only hosting exits 0
  - HTTP response returns 200 with security headers
  - SPA routing works for deep links

#### T011: Smoke Test -- Auth Flow on Production
- **Agent:** test-engineer
- **Priority:** P0
- **Dependencies:** T009, T010
- **INPUT:** Production URL
- **OUTPUT:** Auth flow verified (register, login, Google sign-in, logout)
- **VERIFY:**
  - New user registration creates Firestore document via onUserCreate trigger
  - Email/password login redirects to dashboard
  - Google sign-in popup completes
  - Protected routes redirect unauthenticated users

#### T012: Smoke Test -- Card CRUD on Production
- **Agent:** test-engineer
- **Priority:** P0
- **Dependencies:** T011
- **INPUT:** Authenticated session on production
- **OUTPUT:** Card lifecycle verified (add, view, redeem, archive)
- **VERIFY:**
  - Add card writes to Firestore
  - Card list displays with correct balances
  - Redeem flow deducts balance and creates transaction
  - Firestore rules block cross-user writes

#### T039: Configure Firebase Authorized Domains
- **Agent:** mobile-developer
- **Priority:** P0
- **Dependencies:** T009
- **INPUT:** Firebase Console Auth settings
- **OUTPUT:** Production domains authorized
- **VERIFY:**
  - web-one-taupe-85.vercel.app added to authorized domains
  - Google Sign-In popup works from all authorized domains


### PHASE 2: SECURITY AUDIT (P0 -- Critical)

#### T013: Firebase API Key Exposure Audit
- **Agent:** security-auditor
- **Priority:** P0
- **Dependencies:** None
- **INPUT:** lib/firebase_options.dart, web/index.html, built JS bundle
- **OUTPUT:** Risk assessment with mitigations
- **VERIFY:**
  - API key has HTTP referrer restrictions in Google Cloud Console
  - API restrictions set to Firebase services only
  - App Check evaluated for enforcement
  - No additional secrets in client-side code
- **NOTES:**
  - firebase_options.dart is in .gitignore but the file exists and is tracked
  - The Firebase web API key is expected to be public but needs referrer restrictions

#### T014: Firestore Security Rules Deep Audit
- **Agent:** security-auditor
- **Priority:** P0
- **Dependencies:** T009
- **INPUT:** firestore.rules, Cloud Functions source
- **OUTPUT:** Rules audit report
- **VERIFY:**
  - IDOR blocked: User A cannot read/write User B data
  - Role escalation blocked: Users cannot set role to admin
  - Field validation rejects invalid types/values
  - Admin-only collections locked
- **KNOWN GAPS:**
  - validUserData() requires role and plan on create -- onUserCreate uses Admin SDK (bypasses rules)
  - Card validation uses field name retailer but seed data uses retailerName -- MISMATCH
  - Transaction validation requires retailer but some code writes retailerName

#### T015: Cloud Functions Security Audit
- **Agent:** security-auditor
- **Priority:** P0
- **Dependencies:** None
- **INPUT:** All functions/src/*.ts files
- **OUTPUT:** Functions security report
- **VERIFY:**
  - All callable functions have auth gate (CONFIRMED: all 4)
  - All admin functions check isAdmin() (CONFIRMED)
  - Input validation present (CONFIRMED)
  - seedMockData MUST be disabled for production (CRITICAL)
  - broadcastNotification has no input length limits (MISSING)
  - exportUserData has no rate limiting (MISSING)
  - setAdminClaim has no revoke capability (MISSING)

#### T016: Client-Side Auth Security Audit
- **Agent:** security-auditor
- **Priority:** P0
- **Dependencies:** None
- **INPUT:** All auth screens, google_sign_in_helper.dart, providers
- **OUTPUT:** Auth security report
- **VERIFY:**
  - Password validation enforces strength requirements (CONFIRMED)
  - No password stored in state after submission (CONFIRMED)
  - Google Sign-In uses correct OAuth flow per platform (CONFIRMED)
  - Auth state propagates via stream provider (CONFIRMED)
- **FINDING:**
  - delete_account_screen.dart uses Dio HTTP POST instead of Firebase callable SDK
  - This bypasses the callable protocol and likely causes unauthenticated errors
  - Fix: Replace with FirebaseFunctions.instance.httpsCallable()

#### T017: Encryption Service Audit
- **Agent:** security-auditor
- **Priority:** P1
- **Dependencies:** None
- **INPUT:** encryption.dart, secure_storage.dart
- **OUTPUT:** Encryption audit report
- **VERIFY:**
  - AES-256-CBC with random IV per encryption (CONFIRMED)
  - Key stored in platform secure storage (CONFIRMED)
  - Key is 32 bytes from SecureRandom (CONFIRMED)
  - No hardcoded keys or IVs (CONFIRMED)
- **OBSERVATIONS:**
  - AES-CBC without HMAC means no ciphertext authentication. Consider AES-GCM.
  - Encryption key is device-local. Multi-device users lose access to encrypted data.
  - CardRedeemScreen displays cardNumberEncrypted/pinEncrypted without decrypting

#### T018: Storage Rules and Upload Security Audit
- **Agent:** security-auditor
- **Priority:** P1
- **Dependencies:** None
- **INPUT:** storage.rules, avatar upload code
- **OUTPUT:** Storage security report
- **VERIFY:**
  - Users can only read/write their own path (CONFIRMED)
  - 5MB file size limit (CONFIRMED)
  - Content type restricted to image/* (CONFIRMED)
- **OBSERVATION:**
  - image/* accepts image/svg+xml which can contain XSS payloads
  - Restrict to image/jpeg, image/png, image/webp specifically

---

### PHASE 3: MISSING FEATURES (P1 -- Core)

#### T019: Implement Apple Sign-In
- **Agent:** mobile-developer
- **Priority:** P1
- **Dependencies:** None (requires Apple Developer account)
- **INPUT:** 3 auth screens with TODO stubs (welcome, login, register)
- **OUTPUT:** Working Apple Sign-In across all 3 screens
- **VERIFY:**
  - sign_in_with_apple package already in pubspec.yaml
  - Create apple_sign_in_helper.dart mirroring google_sign_in_helper.dart
  - Web: SignInWithApple.getAppleIDCredential() with redirect URI
  - iOS: Native Apple Sign-In flow
  - Firebase Console: Apple provider enabled
  - All 3 screens call helper on Apple button tap

#### T020: Implement Card Detail Action Stubs
- **Agent:** mobile-developer
- **Priority:** P1
- **Dependencies:** None
- **INPUT:** card_detail_screen.dart with 5 TODO stubs
- **OUTPUT:** All card actions functional
- **VERIFY:**
  - Update Balance: opens balance check bottom sheet
  - Edit Card: navigates to edit flow
  - Archive Card: sets status to archived with confirmation
  - Delete Card: confirmation dialog then Firestore delete
  - All actions create audit trail in transactions

#### T021: Implement Onboarding Stubs
- **Agent:** mobile-developer
- **Priority:** P1
- **Dependencies:** None
- **INPUT:** onboarding_first_card_screen.dart, onboarding_security_screen.dart
- **OUTPUT:** Onboarding flows write to Firestore
- **VERIFY:**
  - First card saves to users/{uid}/cards/
  - Security screen persists MFA/biometric preferences
  - onboardingComplete flag set to true

#### T022: Implement MFA/Biometric/Verify-Email Stubs
- **Agent:** mobile-developer
- **Priority:** P1
- **Dependencies:** None
- **INPUT:** mfa_challenge_screen.dart, biometric_lock_screen.dart, verify_email_screen.dart
- **OUTPUT:** Auth challenge screens functional
- **VERIFY:**
  - MFA: Verifies TOTP code via Firebase Auth multi-factor
  - Biometric: Uses local_auth package to authenticate
  - Email verification: Uses FirebaseAuth.currentUser.sendEmailVerification()

---

### PHASE 4: CODE QUALITY (P1 -- Maintainability)

#### T023: Fix Firestore Schema Mismatch
- **Agent:** mobile-developer
- **Priority:** P1
- **INPUT:** Rules validate retailer, seed data writes retailerName
- **OUTPUT:** Consistent field naming across all layers
- **VERIFY:** All writes pass Firestore validation rules

#### T024: Fix DeleteAccountScreen Callable Invocation
- **Agent:** mobile-developer
- **Priority:** P1
- **INPUT:** delete_account_screen.dart using Dio HTTP call at line 331
- **OUTPUT:** Proper Firebase callable invocation
- **VERIFY:**
  - Replace Dio with FirebaseFunctions.instance.httpsCallable()
  - Add cloud_functions package to pubspec.yaml explicitly
  - Delete account flow completes on production

#### T025: Remove or Gate seedMockData Function
- **Agent:** security-auditor
- **Priority:** P1
- **Dependencies:** T015
- **INPUT:** seedMockData.ts, index.ts
- **OUTPUT:** seedMockData disabled for production
- **VERIFY:** Function not callable in production environment

#### T027: Resolve Remaining TODO Stubs Audit
- **Agent:** mobile-developer
- **Priority:** P2
- **Dependencies:** T019, T020, T021, T022
- **INPUT:** 15 TODO comments across codebase
- **OUTPUT:** All TODOs implemented or documented in BACKLOG.md
- **VERIFY:** All TODO comments resolved

---

### PHASE 5: TEST COVERAGE (P1 -- Quality)

#### T028: Add Provider Unit Tests
- **Agent:** test-engineer
- **Priority:** P1
- **INPUT:** 5 provider files (only auth has coverage)
- **OUTPUT:** Tests for card, transaction, notification, admin providers
- **VERIFY:** flutter test passes with new tests using mock Firestore

#### T029: Add Screen Widget Tests for Critical Flows
- **Agent:** test-engineer
- **Priority:** P1
- **INPUT:** login, register, card_redeem, delete_account, dashboard screens
- **OUTPUT:** Widget tests for 5 critical screens
- **VERIFY:** Login (validation, lockout), Register (strength meter), Card redeem (reveal/hide), Delete account (confirmation), Dashboard (rendering)

#### T030: Add Cloud Functions Unit Tests
- **Agent:** test-engineer
- **Priority:** P1
- **INPUT:** 11 TypeScript files, 0 existing tests
- **OUTPUT:** Jest test suite for Cloud Functions
- **VERIFY:** Tests for 4 callables, 2 scheduled, 1 trigger; npm test passes

#### T031: Add Firestore Rules Unit Tests
- **Agent:** test-engineer
- **Priority:** P1
- **INPUT:** firestore.rules
- **OUTPUT:** Rules unit tests using @firebase/rules-unit-testing
- **VERIFY:** Owner/non-owner/admin access, field validation, role escalation prevention

#### T032: Expand Playwright E2E Coverage
- **Agent:** test-engineer
- **Priority:** P2
- **Dependencies:** T011, T012
- **INPUT:** 4 existing spec files (40 tests)
- **OUTPUT:** Additional specs for auth and card flows
- **VERIFY:** npx playwright test passes with new specs

---

### PHASE 6: PERFORMANCE (P2 -- Optimization)

#### T033: Flutter Web Bundle Size Audit
- **Agent:** performance-optimizer
- **Priority:** P2
- **OUTPUT:** Bundle size report (target under 3MB gzipped, deferred loading for admin, font subsetting)

#### T034: Firestore Query Performance Review
- **Agent:** performance-optimizer
- **Priority:** P2
- **OUTPUT:** Query optimization report (N+1 patterns in scheduled functions, index coverage)

#### T035: Image/Asset Loading Optimization
- **Agent:** performance-optimizer
- **Priority:** P2
- **OUTPUT:** Asset optimization (lazy loading, caching, size reduction)

---

### PHASE 7: INFRASTRUCTURE (P2 -- Operational)

#### T036: Add Firebase App Check
- **Agent:** security-auditor
- **Priority:** P2
- **Dependencies:** T009
- **OUTPUT:** App Check enabled (reCAPTCHA for web, Play Integrity for Android, App Attest for iOS)

#### T037: Add Firebase Crashlytics Integration
- **Agent:** mobile-developer
- **Priority:** P2
- **OUTPUT:** Crashlytics initialized (FlutterError.onError, async errors, test crash visible)

#### T038: Add Firebase Analytics Events
- **Agent:** mobile-developer
- **Priority:** P2
- **OUTPUT:** Key events tracked (screen views via GoRouter observer, card_added, card_redeemed, purchase_recorded)

---

## 7. Dependency Graph

T009 (Firebase Deploy)
  -> T010 (Hosting) -> T011 (Auth Smoke) -> T012 (Card Smoke) -> T032 (E2E)
  -> T014 (Rules Audit)
  -> T039 (Auth Domains)
  -> T036 (App Check)

Independent Security (parallel): T013, T015 -> T025, T016, T017, T018
Independent Features (parallel): T019, T020, T021, T022
Code Quality: T023, T024, T025 (dep: T015), T027 (dep: T019-T022)
Tests (parallel): T028, T029, T030, T031
Performance (parallel): T033, T034, T035
Infrastructure: T036 (dep: T009), T037, T038

---

## 8. Known Security Findings (Pre-Audit Summary)

| ID | Severity | Finding | File | Task |
|----|----------|---------|------|------|
| SEC-001 | CRITICAL | seedMockData callable in production | functions/src/callable/seedMockData.ts | T025 |
| SEC-002 | HIGH | DeleteAccount uses Dio HTTP instead of callable SDK | delete_account_screen.dart:331 | T024 |
| SEC-003 | HIGH | Firestore field mismatch: rules vs seed data vs client | firestore.rules + seedMockData.ts | T023 |
| SEC-004 | MEDIUM | AES-CBC without HMAC (no ciphertext auth) | encryption.dart | T017 |
| SEC-005 | MEDIUM | Storage rules accept image/svg+xml (XSS risk) | storage.rules:10 | T018 |
| SEC-006 | MEDIUM | broadcastNotification no input length limits | broadcastNotification.ts | T015 |
| SEC-007 | LOW | Client-side login lockout resets on reload | login_screen.dart | Acceptable |
| SEC-008 | LOW | No rate limiting on exportUserData | exportUserData.ts | T015 |
| SEC-009 | INFO | firebase_options.dart in .gitignore but tracked | .gitignore:47 | T013 |

---

## 9. Execution Priority Order

### Immediate (P0)
1. T009 -- Deploy Firebase (user CLI auth required)
2. T039 -- Configure authorized domains
3. T010 -- Deploy hosting
4. T013 -- API key audit (parallel with deploy)
5. T015 -- Functions security audit (parallel)
6. T016 -- Auth security audit (parallel)
7. T014 -- Rules deep audit (after T009)
8. T011 -- Auth smoke test
9. T012 -- Card CRUD smoke test

### High (P1)
10. T024 -- Fix DeleteAccount callable
11. T023 -- Fix schema mismatch
12. T025 -- Gate seedMockData
13. T017 -- Encryption audit
14. T018 -- Storage audit
15. T019 -- Apple Sign-In
16. T020 -- Card detail actions
17. T021 -- Onboarding stubs
18. T022 -- MFA/biometric stubs
19. T028 -- Provider tests
20. T029 -- Screen widget tests
21. T030 -- Functions tests
22. T031 -- Rules tests

### Polish (P2)
23. T027 -- TODO audit
24. T032 -- Expand E2E
25. T033 -- Bundle size audit
26. T034 -- Query performance
27. T035 -- Asset optimization
28. T036 -- App Check
29. T037 -- Crashlytics
30. T038 -- Analytics

---

## 10. Phase X: Final Verification Checklist

- [ ] flutter analyze returns 0 issues
- [ ] flutter test passes all tests (246+ current plus new)
- [ ] npx playwright test passes all E2E (40+ current plus new)
- [ ] Firebase Console shows 9 Cloud Functions deployed and healthy
- [ ] Firestore Rules playground rejects unauthorized operations
- [ ] Production URL loads within performance budget (LCP under 3s)
- [ ] Security tasks T013-T018 completed with no critical findings open
- [ ] All TODO comments resolved or documented in BACKLOG.md
- [ ] No hardcoded secrets in committed code
- [ ] .gitignore covers all secret files
- [ ] Firebase authorized domains configured for production URLs
- [ ] Google Sign-In works on production
- [ ] Apple Sign-In works on production (or deferred with Coming Soon toast)
- [ ] Card CRUD lifecycle verified on production
- [ ] Admin dashboard accessible only to admin-claim users
- [ ] Delete account flow completes successfully
- [ ] seedMockData disabled or removed from production

---

## 11. Notes

1. **Firebase CLI Auth Blocker:** T009 requires interactive firebase login. User must run this manually.

2. **Apple Sign-In Prerequisites:** Requires Apple Developer Program membership, Service ID configuration, and private key upload to Firebase. If not available, defer T019 and show a Coming Soon toast instead of a no-op button.

3. **Dual Deployment Strategy:** The app is currently on Vercel (production) and Firebase Hosting (pending T010). Consider consolidating to Firebase Hosting since Cloud Functions, Firestore, and Auth are all Firebase services.

4. **Encryption Key Portability:** The AES-256 encryption key is stored in device-local secure storage. If a user logs in from a new device, they cannot decrypt their card numbers. A key derivation or server-side key escrow strategy should be evaluated for multi-device support.

5. **Cloud Functions v1 vs v2:** The codebase uses firebase-functions v5 but with v1 API patterns (functions.https.onCall, functions.pubsub.schedule). Consider migrating to v2 API for better cold-start performance and concurrency control.
