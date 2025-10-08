#!/usr/bin/env bash
# Simple deploy script: builds Flutter web and pushes to gh-pages branch
# Usage: ./deploy_to_github_pages.sh

set -euo pipefail

# Config - change only if you must
GITHUB_USERNAME="Slof1ny"
REPO_NAME="kitchen"
REMOTE_NAME="origin"

echo "1/6: ensuring flutter is available..."
if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter not found in PATH. Please install Flutter and add it to PATH."
  exit 1
fi

echo "2/6: fetching pub packages..."
flutter pub get

echo "3/6: building web release..."
flutter build web --release

echo "4/6: preparing orphan gh-pages branch..."
git fetch ${REMOTE_NAME} || true
git checkout --orphan gh-pages
git reset --hard

echo "5/6: adding build/web contents and committing..."
git --work-tree build/web add --all
git --work-tree build/web commit -m "Deploy Flutter web to gh-pages"

echo "6/6: pushing to remote gh-pages branch..."
git push ${REMOTE_NAME} HEAD:gh-pages --force

echo "Deployment finished. Set GitHub Pages source to gh-pages branch in repository settings if not already set."

echo "Your site should be at: https://${GITHUB_USERNAME}.github.io/${REPO_NAME}/"
