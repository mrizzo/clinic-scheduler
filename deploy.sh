#!/usr/bin/env bash
#
# deploy.sh — publish the clinic scheduler to Cloudflare Pages.
#
# Deploys from the local folder (NOT via Git), so configs.local.json — which is
# gitignored and holds private clinic presets — is included in the upload. A
# Git-connected deploy would skip it.
#
# The site MUST be gated by Cloudflare Access (see DEPLOY.md, step 4): the
# uploaded configs.local.json is a publicly fetchable file until Access is on.
#
# Usage:
#   ./deploy.sh              # deploy the current directory
# First run only:
#   npx wrangler login       # interactive, opens a browser
#
set -euo pipefail

PROJECT="${PAGES_PROJECT:-clinic-scheduler}"
cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ ! -f configs.local.json ]]; then
  echo "!  configs.local.json not found — deploying without private presets."
  echo "   (Only configs.json's public examples will be available.)"
fi

echo "Deploying ./ to Cloudflare Pages project '$PROJECT'…"
npx wrangler pages deploy . --project-name "$PROJECT"

echo
echo "Done. If this is a first deploy, finish in the Cloudflare dashboard:"
echo "  1. Pages > $PROJECT > Custom domains > add dragonfly-labs.com"
echo "  2. Zero Trust > Access > Applications > gate dragonfly-labs.com to your email"
echo "  (see DEPLOY.md)"
