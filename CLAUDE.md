# Clinic Scheduler — Project Config

A tiny, generic **add-to-calendar generator**. Anyone types an event — title,
date, time, duration, optional location/notes — and gets a **QR code**, an
**`.ics` file**, an **email draft**, or a **copyable calendar link** to add it
to their own calendar. It is *not* tied to any one clinic or person; a clinic is
just one instance (you type the clinic name as the title, the doctor in notes).

It grew out of a specific annoyance: some clinics hand out a paper appointment
card (診察券) with the next visits written by hand, and if you don't re-type them
into your phone you forget the appointment. This tool removes the re-typing:
fill the fields once, scan/import, done.

> Presets in `configs.json` are shipped in the repo and therefore public. Keep
> only non-sensitive, generic examples here — don't commit a real clinic a user
> would rather not disclose (e.g. a personal doctor). Real presets can be added
> locally or hosted privately.

## Design principles

- **Generic first.** No hardcoded clinic, patient, or doctor. Clinic-specific
  data lives in `configs.json` presets, never in the page.
- **No backend, no build, no upload.** A single static `index.html`; the QR
  library loads from a CDN. Everything runs in the browser — appointment/PII
  data never leaves the device. Host it anywhere (or open the file directly).
- **The user confirms, the tool never guesses silently.** No OCR of cards. The
  human types or verifies every date/time.

## Files

| File | Purpose |
|---|---|
| `index.html` | The whole app — form, live QR, `.ics`/email/link/Maps buttons. |
| `configs.json` | Optional clinic presets, loaded by `?cfg=<name>`. |
| `CLAUDE.md` | This file. |

## Presets (`?cfg=<name>`)

`index.html?cfg=example-clinic` fetches `configs.json`, looks up that key, and
pre-fills the clinic fields — leaving date/time (and the doctor) to the user.
Unknown or missing keys fall back to the plain generic tool. A preset entry:

```json
{
  "example-clinic": {
    "title": "Example Clinic — Appointment",
    "location": "Example Clinic, 1-2-3 Somewhere, Tokyo",
    "notesTemplate": "TEL 00-0000-0000\nhttps://example.com\nDoctor: ",
    "durationMin": 60
  }
}
```

- `title` → event summary. `location` → event location (calendars auto-link it
  to Maps; the 📍 button also opens it in Google Maps).
- `notesTemplate` → seeds the notes box; end it with `Doctor: ` so the user just
  appends the name they saw.
- `durationMin` → default duration.

Adding a clinic is a `configs.json` edit — no code change. Fields transcribed
from a card or website (address, phone, hours) should be **verified against the
clinic's own site** before sharing a `?cfg=` link.

## Output mechanics (and their honest limits)

- **QR** encodes a **Google Calendar** add-event URL (`calendar.google.com/
  calendar/render?action=TEMPLATE&…`). Chosen because a QR of raw `.ics`/VEVENT
  text does not reliably add to phone calendars, whereas the GCal link opens
  cross-platform via the browser. Apple Calendar / Outlook users use the `.ics`.
- **`.ics`** is a floating-local-time VEVENT with two `VALARM` reminders (1 day
  and 2 hours before) — the anti-forgetting feature. Universal: Apple, Outlook,
  Google all import it.
- **Email** uses `mailto:`, so it carries the calendar **link**, not an `.ics`
  attachment (browsers can't attach files via `mailto:`).
- **Times are floating/local** (same wall-clock everywhere). The "when" line
  shows the viewer's own IANA timezone for confirmation.

## Location / Maps

Live "type a name → auto-fill address" would require the Google **Places API**
(Cloud key + billing; the key is exposed in a static page, so it must be
referrer-restricted). Deliberately **not** used — presets plus the address text
(which calendars auto-link) plus the 📍 Maps-search button cover the real need
with zero API cost. Revisit only if arbitrary any-clinic lookup is needed.

## Try it locally

```bash
python3 -m http.server 8096 --directory /path/to/clinic-scheduler
# http://localhost:8096/index.html                  generic
# http://localhost:8096/index.html?cfg=example-clinic   with a preset
```
