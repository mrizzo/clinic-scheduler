// GET /clinic-scheduler/ics?title=&start=&end=&location=&notes=
//
// Returns the event as a real text/calendar HTTP response so mobile browsers
// open the DEFAULT calendar in one tap (iPhone → Apple Calendar, Android →
// default). A static page can't produce this content-type for itself, which is
// the whole reason this endpoint exists. start/end are floating local time,
// "YYYYMMDDTHHMMSS". No data is stored — the response is generated per request.
export function onRequestGet({ request }) {
  const p = new URL(request.url).searchParams;
  const esc = (s) =>
    s.replace(/\\/g, "\\\\").replace(/\n/g, "\\n").replace(/,/g, "\\,").replace(/;/g, "\\;");
  const title = p.get("title") || "Appointment";
  const start = (p.get("start") || "").replace(/[^0-9T]/g, "");
  const end = (p.get("end") || "").replace(/[^0-9T]/g, "");
  const loc = p.get("location") || "";
  const notes = p.get("notes") || "";

  if (!/^\d{8}T\d{6}$/.test(start) || !/^\d{8}T\d{6}$/.test(end)) {
    return new Response("Bad start/end", { status: 400 });
  }

  const dtstamp = new Date().toISOString().replace(/[-:]/g, "").replace(/\.\d{3}Z$/, "Z");
  const uid = `${start}-${Math.random().toString(36).slice(2)}@add-to-calendar`;
  const lines = [
    "BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//add-to-calendar//EN", "CALSCALE:GREGORIAN",
    "BEGIN:VEVENT",
    `UID:${uid}`,
    `DTSTAMP:${dtstamp}`,
    `DTSTART:${start}`,
    `DTEND:${end}`,
    `SUMMARY:${esc(title)}`,
    ...(loc ? [`LOCATION:${esc(loc)}`] : []),
    ...(notes ? [`DESCRIPTION:${esc(notes)}`] : []),
    "BEGIN:VALARM", "ACTION:DISPLAY", `DESCRIPTION:${esc(title)}`, "TRIGGER:-P1D", "END:VALARM",
    "BEGIN:VALARM", "ACTION:DISPLAY", `DESCRIPTION:${esc(title)}`, "TRIGGER:-PT2H", "END:VALARM",
    "END:VEVENT", "END:VCALENDAR",
  ];
  const filename =
    (title.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") || "event") + ".ics";

  return new Response(lines.join("\r\n") + "\r\n", {
    headers: {
      "content-type": "text/calendar; charset=utf-8",
      "content-disposition": `inline; filename="${filename}"`,
      "cache-control": "no-store",
    },
  });
}
