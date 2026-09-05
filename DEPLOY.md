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

Deploy from disk (not Git) so `configs.local.json` is included — a Git-connected
deploy skips it because it's `.gitignore`d.

```bash
npx wrangler login        # first time only — opens a browser
./deploy.sh               # = npx wrangler pages deploy . --project-name clinic-scheduler
```

This uploads `index.html`, `configs.json`, and `configs.local.json`, and prints a
`clinic-scheduler.pages.dev` URL. Re-run `./deploy.sh` any time you edit configs.

## 3. Custom domain

Pages project → **Custom domains** → add **`dragonfly-labs.com`** (and optionally
`www.`). Cloudflare creates the DNS record automatically since the domain is on
Cloudflare.

## 4. Lock it to you (required)

Cloudflare **Zero Trust → Access → Applications → Add a self-hosted application**:

- **Application domain:** `dragonfly-labs.com`
- **Policy:** Allow — **Emails** — your address only (e.g. the Gmail you use)
- **Login method:** **Email OTP** (Cloudflare emails a one-time code; no password
  to manage)

Now the whole site, including `configs.local.json`, is unreachable to anyone but
you. Test in a private window: you should hit the Cloudflare login first.

## Notes

- **Updating configs:** edit `configs.local.json` locally, then `./deploy.sh`.
- **Never commit `configs.local.json`** — it stays local; the deploy uploads it
  directly. Only non-sensitive examples belong in the tracked `configs.json`.
- **Preset URLs** (once live): `https://dragonfly-labs.com/?cfg=yotsuya-yui`, etc.
