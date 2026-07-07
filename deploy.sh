#!/usr/bin/env bash
set -euo pipefail

# Vaulted App — Full Deploy Script
# Prerequisites: firebase login, flutter build web --release already done

PROJECT="vaulted-app-c89d2"
echo "=== Deploying to $PROJECT ==="

# 1. Deploy Firestore rules + indexes
echo "[1/4] Deploying Firestore rules & indexes..."
firebase deploy --only firestore --project "$PROJECT"

# 2. Deploy Storage rules
echo "[2/4] Deploying Storage rules..."
firebase deploy --only storage --project "$PROJECT"

# 3. Deploy Cloud Functions
echo "[3/4] Deploying Cloud Functions..."
firebase deploy --only functions --project "$PROJECT"

# 4. Deploy Hosting (Flutter web build)
echo "[4/4] Deploying Flutter web to Firebase Hosting..."
firebase deploy --only hosting --project "$PROJECT"

echo ""
echo "=== Deploy complete ==="
echo "Production URL: https://$PROJECT.web.app"
echo ""
echo "Next: Run smoke tests against the production URL"
echo "  PROD_URL=https://$PROJECT.web.app npx playwright test --reporter=list"
