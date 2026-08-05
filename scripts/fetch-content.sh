#!/usr/bin/env bash

set -euo pipefail

: "${WIKI_REPO:?WIKI_REPO must contain OWNER/REPOSITORY}"

WIKI_BRANCH="${WIKI_BRANCH:-main}"

rm -rf content

if [[ -n "${WIKI_REPO_URL:-}" ]]; then
  REPO_URL="$WIKI_REPO_URL"
elif [[ -n "${WIKI_REPO_TOKEN:-}" ]]; then
  REPO_URL="https://x-access-token:${WIKI_REPO_TOKEN}@github.com/${WIKI_REPO}.git"
else
  REPO_URL="https://github.com/${WIKI_REPO}.git"
fi

echo "Downloading wiki materials from ${WIKI_REPO}, branch ${WIKI_BRANCH}"

git clone \
  --depth 1 \
  --single-branch \
  --branch "$WIKI_BRANCH" \
  "$REPO_URL" \
  content

rm -rf content/.git

if [[ ! -f content/README.md ]]; then
  echo "ERROR: content/README.md was not found"
  exit 1
fi

cp content/README.md content/index.md

echo "Created content/index.md from content/README.md"
echo "Wiki materials downloaded successfully"