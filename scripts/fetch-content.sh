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

ICON_SOURCE="content/desert rose.png"
ICON_DEST="quartz/static/icon.png"

if [[ ! -f "$ICON_SOURCE" ]]; then
  echo "ERROR: $ICON_SOURCE was not found"
  exit 1
fi

mkdir -p quartz/static

node --input-type=module <<'NODE'
import sharp from "sharp"

await sharp("content/desert rose.png")
  .resize(256, 256, {
    fit: "contain",
    background: {
      r: 0,
      g: 0,
      b: 0,
      alpha: 0,
    },
  })
  .png({
    compressionLevel: 9,
  })
  .toFile("quartz/static/icon.png")
NODE

echo "Created 256x256 favicon at ${ICON_DEST}"
echo "Wiki materials downloaded successfully"
