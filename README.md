# Clinic Scheduler

A tiny **add-to-calendar generator**. Type an event — title, date, time,
duration, optional location and notes — and get a **QR code**, an **`.ics`
file**, an **email draft**, or a **copyable calendar link** to drop it onto any
calendar.

It's generic: a clinic is just one use case (type the clinic as the title, the
doctor in the notes). It grew out of one annoyance — clinics that hand out a
paper appointment card, where if you don't re-type the dates into your phone you
forget the appointment. This removes the re-typing.

- **No backend, no build, no upload.** One static `index.html`; the QR library
  loads from a CDN. Everything runs in the browser — nothing you type leaves the
  device. Host it anywhere, or just open the file.
- **The `.ics` includes reminders** (1 day + 2 hours before) — the whole point
  is not forgetting.

## Use it

```bash
python3 -m http.server 8096 --directory .
# then open http://localhost:8096/index.html
```

Or open `index.html` directly in a browser (presets need it served over
`http://` — see below).

1. Fill in the title, date, and time (duration/location/notes optional).
2. The **QR code updates live** — scan it with a phone camera to add the event
   to Google Calendar.
3. Or **Download .ics** (Apple Calendar / Outlook / Google — universal),
   **Email it**, **Copy calendar link**, or **Open location in Maps**.

## Clinic presets (`?cfg=<name>`)

`index.html?cfg=example-clinic` pre-fills the clinic fields from
[`configs.json`](configs.json), leaving the date, time, and doctor to the user.
Add a clinic by adding an entry — no code change:

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

Unknown or missing keys fall back to the plain generic tool. Presets are read
over `http://` (`fetch`), so use a local server rather than `file://` for them.

> **`configs.json` ships in the repo — treat it as public.** Keep only
> non-sensitive example clinics here; don't commit a real personal doctor.

## How the outputs work (and their limits)

| Output | What it is | Note |
|---|---|---|
| **QR** | A Google Calendar add-event link | A QR of raw `.ics` text doesn't reliably add to phone calendars; the GCal link does. Apple/Outlook users use the `.ics`. |
| **.ics** | A floating-local-time event with two reminders | Universal — Apple, Outlook, Google all import it. |
| **Email** | A `mailto:` draft | Carries the calendar **link**, not an `.ics` attachment (browsers can't attach files via `mailto:`). |
| **Maps** | A Google Maps search for the location | Calendars also auto-link the address text on their own. |

Times are floating/local (same wall-clock everywhere); the app shows your
timezone for confirmation.

## Why not auto-fill an address from Maps?

Live "type a name → fill the address" needs the Google **Places API** — a Cloud
key with billing, and the key would be exposed in a static page (so it'd need
referrer restrictions). Not worth it for a small fixed list of clinics: presets
plus the address text plus the Maps button cover the real need at zero cost.

## Files

| File | Purpose |
|---|---|
| `index.html` | The whole app. |
| `configs.json` | Optional clinic presets. |
| `CLAUDE.md` | Design notes / project context. |
