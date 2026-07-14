import { useEffect, useMemo, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { Tutors, Bookings } from "../api/client.js";
import { useAuth } from "../context/AuthContext.jsx";
import { useToast } from "../context/ToastContext.jsx";
import { EmptyState, ErrorState, Skeleton } from "../components/Feedback.jsx";

const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

export default function TutorProfile() {
  const { id } = useParams();
  const { isAuthed, isStudent } = useAuth();
  const toast = useToast();

  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState(null);
  const [bookingErr, setBookingErr] = useState(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    let alive = true;
    setLoading(true);
    Tutors.get(id)
      .then((d) => alive && setData(d))
      .catch((e) => alive && setErr(e.message))
      .finally(() => alive && setLoading(false));
    return () => { alive = false; };
  }, [id]);

  const grouped = useMemo(() => {
    if (!data) return [];
    const map = data.availabilities_by_day || {};
    return DAYS.map((label, idx) => ({
      day: idx,
      label,
      windows: map[String(idx)] || map[idx] || []
    })).filter((g) => g.windows.length > 0);
  }, [data]);

  const nextDateForDay = (dayIdx) => {
    const today = new Date();
    const cur = today.getDay();
    let delta = (dayIdx - cur + 7) % 7;
    if (delta === 0) delta = 7; // skip today, push to next occurrence
    const d = new Date(today);
    d.setDate(today.getDate() + delta);
    return d.toISOString().slice(0, 10);
  };

  const bookSlot = async (window) => {
    if (!isAuthed) {
      toast.info("Please sign in to book.");
      return;
    }
    if (!isStudent) {
      toast.error("Only student accounts can book sessions.");
      return;
    }
    setBookingErr(null);
    setBusy(true);
    try {
      await Bookings.create({
        tutor_id: data.tutor.user_id,
        booking_date: nextDateForDay(window.day_of_week),
        start_time: window.start_time,
        end_time: window.end_time
      });
      toast.success("Booking requested! See it in My bookings.");
    } catch (e) {
      setBookingErr(e.message);
    } finally {
      setBusy(false);
    }
  };

  if (loading) {
    return (
      <div className="container-editorial py-12">
        <Skeleton className="h-48 mb-6" />
        <Skeleton className="h-32" />
      </div>
    );
  }

  if (err) return <div className="container-editorial py-12"><ErrorState message={err} /></div>;
  if (!data) return null;

  const t = data.tutor;

  return (
    <div className="container-editorial py-12">
      <Link to="/tutors" className="nav-link focus-ring inline-block mb-6">← All tutors</Link>

      {/* Hero */}
      <header className="tile-accent-white rounded-2xl p-8 md:p-10 mb-10">
        <div className="font-mono uppercase text-tag tracking-[0.18em] text-absolute/70">{t.subject || "General tutoring"}</div>
        <h1 className="font-display text-display-md mt-3 leading-[0.92] text-absolute">
          {t.user?.name}
        </h1>
        {t.headline && <p className="mt-4 text-headline-sm text-absolute/80 max-w-readable">{t.headline}</p>}

        <div className="mt-8 grid grid-cols-2 md:grid-cols-4 gap-4">
          <Meta label="Hourly rate" value={`$${Number(t.hourly_rate).toFixed(2)}`} />
          <Meta label="Member since" value={new Date(t.user?.created_at).toLocaleDateString()} />
          <Meta label="Email" value={t.user?.email} />
          <Meta label="Avg rating" value={t.average_rating ? `${t.average_rating.toFixed(1)} / 5` : "—"} />
        </div>
      </header>

      {/* Bio */}
      {t.bio && (
        <section className="mb-10 max-w-readable">
          <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint mb-3">/ About</div>
          <p className="text-headline-sm text-hazard-muted leading-relaxed whitespace-pre-line">
            {t.bio}
          </p>
        </section>
      )}

      {/* Availability */}
      <section>
        <div className="flex items-center justify-between mb-6 gap-4 flex-wrap">
          <div>
            <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">/ Availability</div>
            <h2 className="font-display text-headline-lg mt-2">Pick a slot</h2>
          </div>
          {!isAuthed && (
            <Link to="/login" className="pill pill--outline pill--small focus-ring">Sign in to book</Link>
          )}
        </div>

        {bookingErr && (
          <div className="rounded-md border border-ultraviolet bg-ultraviolet/15 px-4 py-3 text-label text-white mb-6">
            {bookingErr}
          </div>
        )}

        {grouped.length === 0 ? (
          <EmptyState title="This tutor hasn't published any availability yet." hint="Check back later." />
        ) : (
          <div className="space-y-5">
            {grouped.map((g) => (
              <div key={g.day} className="rounded-xl bg-canvas border border-hazard-white/15 p-5">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">{DAYS[g.day]}</div>
                    <h3 className="font-display text-headline-md mt-1">{g.label} slots</h3>
                  </div>
                  <span className="font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">
                    {g.windows.length} {g.windows.length === 1 ? "window" : "windows"}
                  </span>
                </div>

                <ul className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                  {g.windows.map((w) => (
                    <li key={w.id} className="flex items-center justify-between rounded-lg border border-hazard-white/15 bg-slate-900 px-4 py-3">
                      <div>
                        <div className="font-display text-2xl leading-none">{w.start_time}</div>
                        <div className="font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">
                          → {w.end_time} · {w.length_minutes}min
                        </div>
                      </div>
                      <button
                        disabled={busy || !isStudent}
                        onClick={() => bookSlot(w)}
                        className="pill pill--primary pill--small focus-ring disabled:opacity-40"
                      >
                        {isStudent ? "Book" : isAuthed ? "Students only" : "Sign in"}
                      </button>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}

function Meta({ label, value }) {
  return (
    <div>
      <div className="font-mono uppercase text-meta tracking-[0.18em] text-absolute/60">{label}</div>
      <div className="text-headline-sm text-absolute mt-1 font-semibold">{value || "—"}</div>
    </div>
  );
}