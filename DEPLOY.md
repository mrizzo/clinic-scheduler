# Deploying to Cloudflare Pages

The clinic scheduler is a static site hosted on **Cloudflare Pages**. It's
deployed **publicly at `https://dragonfly-labs.com/clinic-scheduler/`** with **no
authentication**, by the owner's explicit choice.

> ⚠️ **Privacy note.** This public deploy includes `configs.local.json`, so the
> clinic presets — and the file itself at
> `…/clinic-scheduler/configs.local.json` — are **publicly readable**. That
> reveals the clinics as the owner's appointments. This was a deliberate
> trade for one-tap `?cfg=` presets with no login. To make it private again,
> put the site behind **Cloudflare Access** (see "Locking it down" below) or
> stop deploying `configs.local.json`.

## Deploy / redeploy

```bash
cd /path/to/clinic-scheduler
./deploy.sh
```

`deploy.sh` stages `index.html`, `configs.json`, and `configs.local.json` into
`./dist/clinic-scheduler/` and runs `wrangler pages deploy dist`, so the app
serves under the `/clinic-scheduler/` path. Re-run it any time you edit configs.

> **Run it in a real terminal, not through an AI agent / the Claude Code `!`
> prompt.** Publishing `configs.local.json` (medical-adjacent data) to a public
> URL trips the assistant's safety classifier and gets blocked — that guardrail
> is intentional. `wrangler login` is required once.

## One-time setup (already done for dragonfly-labs.com)

1. Domain `dragonfly-labs.com` is on Cloudflare (nameservers moved from A2).
2. A **Pages project** (`clinic-scheduler-u1l.pages.dev`) holds the deploys.
3. That project has **`dragonfly-labs.com` as a custom domain**
   (Workers & Pages → the project → Custom domains).

> Gotcha learned the hard way: deleting and recreating the project can leave a
> **duplicate** `clinic-scheduler` (an old Worker) still holding the domain, so
> the domain serves a stale deploy. Keep exactly **one** `clinic-scheduler`
> app, and make sure the custom domain is attached to the one you deploy to.

## URLs

- `https://dragonfly-labs.com/clinic-scheduler/` — generic tool
- `https://dragonfly-labs.com/clinic-scheduler/?cfg=yotsuya-yui` — a preset
- `…/clinic-scheduler` (no slash) 308-redirects to `…/clinic-scheduler/`,
  query string preserved.

## Locking it down (optional — makes it private again)

Cloudflare **Zero Trust → Access → Applications → Add a self-hosted app**,
hostname `dragonfly-labs.com`, policy Allow → your email only, login **Email
OTP**. That gates the whole site (including `configs.local.json`) so only you
can load it. Removing the Access application removes the gate.
