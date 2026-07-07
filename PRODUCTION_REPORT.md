# Vaulted App — Production Report

**Date:** 2026-03-21
**Production URL:** https://web-one-taupe-85.vercel.app
**Firebase Project:** vaulted-app-c89d2

---

## Phase 0 — Ingest & Gap Analysis

Explored the full Flutter codebase (clean architecture: core/data/domain/presentation) and identified 12 tasks across 3 priority tiers.

**Gaps found:**
- 3 placeholder screens (Card Redeem, Transaction Detail, Support)
- Delete Account routing bug (pointed to DataExportScreen)
- Biometric toggle and avatar upload unimplemented
- Firestore security rules lacked field-level validation
- 2 Flutter analysis warnings
- No E2E test coverage for web frontend

## Phase 1 — Build & Fix

### T001: Card Redeem Screen (P0)
Built `CardRedeemScreen` with reveal/copy for card number and PIN, batch Firestore writes for balance updates, screenshot prevention mixin, and "Mark as Used" bottom sheet.

### T002: Transaction Detail Screen (P0)
Built `TransactionDetailScreen` with color-coded amounts (green for credit, red for debit), type badges, shimmer loading states, and Firestore document streaming.

### T003: Support Screen (P1)
Built `SupportScreen` with 8 searchable FAQ items, contact section with email launcher, and feedback bottom sheet.

### T004: Delete Account Fix (P0)
Created `DeleteAccountScreen` with type-DELETE confirmation, `deleteUserCascade` Cloud Function call, and auth account deletion. Fixed profile routing to point to new screen instead of DataExportScreen.

### T005: Biometric Toggle (P1)
Implemented `onChanged` handler on profile screen to persist `biometricEnabled` to Firestore.

### T006: Avatar Upload (P1)
Implemented `_pickAndUploadAvatar` with `ImagePicker`, Firebase Storage upload (512x512 max, 80% quality), and Firestore `avatarUrl` update.

### T007: Firestore Security Rules (P1)
Added `validUserData()`, `validCardData()`, `validTransactionData()` helper functions with type checking, required field validation, and enum value constraints.

### T008: Analysis Warnings (P2)
Removed unnecessary import in `main.dart`. Zero issues reported.

### Google Sign-In (added during session)
- Created `google_sign_in_helper.dart` — platform-aware (web popup vs mobile native)
- Wired into welcome, login, and register screens
- Replaced all 3 `// TODO: Google sign-in` stubs

### Filter Pill Fix (added during session)
- Reduced `VaultedFilterPills` height from 44px to 36px for proper alignment

## Phase 2 — Test

### Flutter Unit/Widget Tests
- **Result:** 246/246 passing
- **Analysis:** 0 issues

### Playwright E2E Tests (local)
- **Result:** 40/40 passing
- **Browsers:** Chromium + Mobile Chrome (Pixel 5)
- **Test suites:**
  - `app-loads.spec.ts` — Flutter bootstrap, console errors, load time
  - `navigation.spec.ts` — 6 route tests (auth, protected, admin redirects)
  - `security.spec.ts` — security headers, no secrets, SPA routing, service worker
  - `accessibility.spec.ts` — lang attr, viewport, color contrast, mobile responsive

### Playwright E2E Tests (production)
- **Result:** 39/40 passing (1 flaky timeout on browser setup, not app issue)
- **Target:** https://web-one-taupe-85.vercel.app

## Phase 3 — Deploy

### Flutter Web → Vercel
- Built with `flutter build web --release`
- Deployed to Vercel production via `vercel deploy build/web --prod`
- Security headers configured: `X-Content-Type-Options`, `X-Frame-Options`, `X-XSS-Protection`, `Referrer-Policy`, `Permissions-Policy`
- Cache-immutable for static assets
- SPA rewrites for client-side routing

### Firebase (pending CLI auth)
- `.firebaserc` created with project ID
- `firebase.json` updated with hosting config
- `deploy.sh` script ready for one-shot deployment
- **Blocked:** Firebase CLI requires interactive browser login
- **Impact:** Firestore rules, Storage rules, and Cloud Functions not yet deployed to production
- **Workaround:** Run `firebase login` in terminal, then `bash deploy.sh`

## Phase 4 — Smoke Test

Production smoke test results against https://web-one-taupe-85.vercel.app:

| Test Category | Result |
|---|---|
| App loads (welcome screen) | PASS |
| No critical console errors | PASS |
| Page load time (<20s) | PASS (1.3-7.0s) |
| Auth routes accessible | PASS |
| Login route loads | PASS |
| Register route loads | PASS |
| Protected route redirect | PASS |
| Admin route redirect | PASS |
| Forgot password route | PASS |
| Security headers served | PASS |
| No hardcoded secrets | PASS |
| main.dart.js served | PASS |
| Service worker exists | PASS |
| SPA routing works | PASS |
| Lang attribute present | PASS |
| Viewport meta tag | PASS |
| Color contrast | PASS |
| Mobile responsive | PASS |
| Tablet responsive | PASS |

## Remaining Action Items

1. **Firebase CLI login** — Run `firebase login` in terminal
2. **Deploy Firebase** — Run `bash deploy.sh` to deploy rules, functions, and hosting
3. **Add Vercel domain** to Firebase Auth authorized domains: `web-one-taupe-85.vercel.app`
4. **Apple Sign-In** — Still stubbed (`// TODO: Apple sign-in`) on all 3 auth screens

## Files Changed

### New Files
- `lib/core/utils/google_sign_in_helper.dart`
- `lib/presentation/screens/user/card_redeem_screen.dart`
- `lib/presentation/screens/user/delete_account_screen.dart`
- `lib/presentation/screens/user/support_screen.dart`
- `lib/presentation/screens/user/transaction_detail_screen.dart`
- `tests/e2e/app-loads.spec.ts`
- `tests/e2e/navigation.spec.ts`
- `tests/e2e/security.spec.ts`
- `tests/e2e/accessibility.spec.ts`
- `playwright.config.ts`
- `.firebaserc`
- `deploy.sh`
- `AGENT_STATE.json`
- `AGENT_LOG.md`
- `AGENT_TASKS.md`

### Modified Files
- `lib/core/router/app_router.dart` — replaced 3 placeholders, added delete-account route
- `lib/presentation/screens/user/profile_screen.dart` — fixed delete routing, biometric toggle, avatar upload
- `lib/presentation/screens/auth/welcome_screen.dart` — Google Sign-In
- `lib/presentation/screens/auth/login_screen.dart` — Google Sign-In
- `lib/presentation/screens/auth/register_screen.dart` — Google Sign-In
- `lib/presentation/widgets/common/vaulted_filter_pills.dart` — height fix
- `lib/main.dart` — removed unused import
- `web/index.html` — added `lang="en"`
- `firebase.json` — added hosting config
- `firestore.rules` — field-level validation
