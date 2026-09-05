#!/usr/bin/env bash
#
# deploy.sh — publish the clinic scheduler to Cloudflare Pages.
#
# Stages ONLY the static site (index.html, configs.json, and the gitignored
# private configs.local.json if present) into a clean temp dir and deploys that.
# This guarantees .git/, .wrangler/, node_modules/, and docs can never be
# uploaded or served — deploying the repo root directly would serve all of them.
#
# The site MUST be gated by Cloudflare Access (see DEPLOY.md, step 4) BEFORE
# dragonfly-labs.com is attached: configs.local.json is a publicly fetchable
# file otherwise.
#
# Usage:
#   ./deploy.sh              # deploy
# First run only:
#   npx wrangler login       # interactive, opens a browser
#
set -euo pipefail

PROJECT="${PAGES_PROJECT:-clinic-scheduler}"
cd "$(dirname "${BASH_SOURCE[0]}")"

# Stage the site into ./dist/clinic-scheduler so it serves at
# https://<domain>/clinic-scheduler/. Per the owner's choice, the presets in
# configs.local.json ARE published here (publicly readable — no auth), so
# ?cfg=<name> pre-fills work for anyone with the link.
rm -rf dist && mkdir -p dist/clinic-scheduler
cp index.html configs.json dist/clinic-scheduler/
if [[ -f configs.local.json ]]; then
  cp configs.local.json dist/clinic-scheduler/
else
  echo "!  configs.local.json not found — deploying without your presets."
fi

echo "Staging dist/clinic-scheduler/: $(cd dist/clinic-scheduler && ls | tr '\n' ' ')"
echo "Deploying to Cloudflare Pages project '$PROJECT'…"
npx wrangler pages deploy dist --project-name "$PROJECT"

echo
echo "Done. If this is a first deploy, finish in the Cloudflare dashboard"
echo "(and set up Access BEFORE adding the custom domain — see DEPLOY.md):"
echo "  1. Zero Trust > Access > Applications > gate dragonfly-labs.com to your email"
echo "  2. Pages > $PROJECT > Custom domains > add dragonfly-labs.com"
