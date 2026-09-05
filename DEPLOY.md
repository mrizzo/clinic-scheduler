# Deploying to Cloudflare Pages (private, on dragonfly-labs.com)

The clinic scheduler is a static site, so it hosts on **Cloudflare Pages** for
free. Because the private presets in `configs.local.json` (personal clinics —
medical data) are fetched as a plain file, the site **must** be gated by
**Cloudflare Access** so only you can load it.

> ⚠️ **Order matters.** Until Access (step 4) is on, `configs.local.json` is a
> publicly downloadable URL. Don't leave the site un-gated once real configs are
> uploaded.

## 1. Put dragonfly-labs.com on Cloudflare

Add the domain in Cloudflare and switch its nameservers at the registrar (A2),
same as any other Cloudflare domain. Wait until it shows **Active**.

## 2. Deploy from the local folder

`deploy.sh` stages only the static site (`index.html`, `configs.json`, and the
gitignored `configs.local.json` if present) into `./dist` and deploys that, so
`.git/`, `.wrangler/`, and docs are never uploaded or served. Deploying the repo
root directly would serve all of them — don't.

```bash
npx wrangler login        # first time only — opens a browser
./deploy.sh               # stages ./dist, then wrangler pages deploy dist
```

Re-run `./deploy.sh` any time you edit configs. `dist/` is a throwaway build dir
(gitignored); `wrangler.jsonc` points Cloudflare's asset directory at it.

## 3. Lock it to you FIRST (required, before the domain is public)

Do this **before** step 4 — dragonfly-labs.com is already in your Cloudflare
zone, so you can gate it now, and Access will protect the site from the first
request instead of leaving an exposure window.

Cloudflare **Zero Trust → Access → Applications → Add a self-hosted application**:

- **Application domain:** `dragonfly-labs.com`
- **Policy:** Allow — **Emails** — your address only (e.g. the Gmail you use)
- **Login method:** **Email OTP** (Cloudflare emails a one-time code; no password
  to manage)

## 4. Custom domain

Pages/Workers project → **Custom domains** → add **`dragonfly-labs.com`** (and
optionally `www.`). Cloudflare creates the DNS record automatically. If a
placeholder record exists at the apex, let it be replaced.

Now the whole site, including `configs.local.json`, is unreachable to anyone but
you. Test in a private window: you should hit the Cloudflare login first, and
`dragonfly-labs.com/configs.local.json` must NOT be readable without logging in.

## Notes

- **Updating configs:** edit `configs.local.json` locally, then `./deploy.sh`.
- **Never commit `configs.local.json`** — it stays local; the deploy uploads it
  directly. Only non-sensitive examples belong in the tracked `configs.json`.
- **Preset URLs** (once live): `https://dragonfly-labs.com/?cfg=example-clinic`, etc.
