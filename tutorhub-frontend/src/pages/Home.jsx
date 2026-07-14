import { Link } from "react-router-dom";
import { useEffect, useState } from "react";
import { Tutors } from "../api/client.js";

export default function Home() {
  const [tutors, setTutors] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let alive = true;
    Tutors.list({ page: 1 })
      .then((data) => { if (alive) setTutors(data?.tutors ?? []); })
      .finally(() => alive && setLoading(false));
    return () => { alive = false; };
  }, []);

  return (
    <div>
      {/* ── Hero / masthead ─────────────────────────────────────── */}
      <section className="bg-canvas border-b border-hazard-white/10">
        <div className="container-editorial pt-16 pb-20 md:pt-24 md:pb-24">
          <div className="font-mono uppercase text-tag tracking-[0.18em] text-mint">
            Independent tutoring · two-sided marketplace
          </div>

          <h1 className="font-display text-display-md md:text-display-lg text-hazard-white mt-5 leading-[0.92]">
            TUTOR<span className="text-mint">HUB</span>
          </h1>

          <p className="font-sans text-headline-sm text-hazard-muted max-w-readable mt-6 leading-snug">
            Students find tutors. Tutors find students. Book a session in three clicks.
          </p>

          <div className="flex flex-wrap items-center gap-3 mt-8">
            <Link to="/tutors" className="pill pill--primary focus-ring">Browse tutors</Link>
            <Link to="/signup" className="pill pill--ultraviolet focus-ring">Create an account</Link>
            <Link to="/login" className="nav-link focus-ring">Sign in</Link>
          </div>
        </div>
      </section>

      {/* ── Storystream: featured tutors ───────────────────────── */}
      <section className="container-editorial py-16">
        <div className="flex items-end justify-between mb-8 gap-4 flex-wrap">
          <div>
            <div className="font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">
              / Storystream
            </div>
            <h2 className="font-display text-display-md mt-3">Featured tutors</h2>
          </div>
          <Link to="/tutors" className="pill pill--secondary pill--small focus-ring">See all</Link>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="skeleton h-44 rounded-xl" />
            ))}
          </div>
        ) : tutors.length === 0 ? (
          <div className="rounded-xl border border-dashed border-hazard-secondary/40 p-12 text-center">
            <p className="font-display text-2xl mb-2">No tutors yet</p>
            <p className="text-hazard-secondary">Once tutors sign up, they'll appear here.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {tutors.slice(0, 6).map((t, idx) => {
              const accent = ["tile-accent-mint", "tile-accent-ultraviolet", "tile-accent-white"][idx % 3];
              return (
                <Link
                  key={t.id}
                  to={`/tutors/${t.id}`}
                  className={`tile ${accent} flex flex-col gap-3 hover:translate-y-[-2px] transition-transform`}
                >
                  <div className="font-mono uppercase text-meta tracking-[0.18em] opacity-80">
                    {t.subject}
                  </div>
                  <div className="font-display text-headline-md leading-tight">{t.user?.name}</div>
                  <p className="text-label opacity-90 line-clamp-2">{t.headline || t.bio || "Independent tutor"}</p>
                  <div className="mt-auto flex items-center justify-between pt-3">
                    <span className="font-mono uppercase text-tag tracking-[0.15em]">
                      ${Number(t.hourly_rate).toFixed(0)}/hr
                    </span>
                    <span className="font-mono uppercase text-meta tracking-[0.18em] opacity-80">
                      View →
                    </span>
                  </div>
                </Link>
              );
            })}
          </div>
        )}
      </section>

      {/* ── Pillars / OOP showcase ──────────────────────────────── */}
      <section className="border-t border-hazard-white/10 bg-slate-900">
        <div className="container-editorial py-16 grid md:grid-cols-3 gap-6">
          <Pillar
            kicker="/ OOP"
            title="Service objects, hand-rolled state machines"
            body="BookingService orchestrates the entire booking flow. Booking#confirm!, #cancel!, #complete! are explicit state transitions with custom exceptions — no AASM gem."
            accent="mint"
          />
          <Pillar
            kicker="/ Concurrency"
            title="Race-proof at the DB level"
            body="Two layers: a unique index on (tutor_id, booking_date, start_time) and optimistic locking via lock_version. 5 threads, 1 winner — proven in the spec."
            accent="ultraviolet"
          />
          <Pillar
            kicker="/ SQL"
            title="Hand-written reports"
            body="ReportQuery ships three raw-SQL reports with NOT EXISTS, GROUP BY and window functions — the same shapes you'd find in a stored procedure."
            accent="white"
          />
        </div>
      </section>
    </div>
  );
}

function Pillar({ kicker, title, body, accent = "mint" }) {
  const accentBg = accent === "mint" ? "bg-mint text-absolute" :
                   accent === "ultraviolet" ? "bg-ultraviolet text-white" :
                   "bg-hazard-white text-absolute";
  return (
    <div className={`rounded-xl p-7 ${accentBg}`}>
      <div className="font-mono uppercase text-meta tracking-[0.18em] opacity-80">{kicker}</div>
      <h3 className="font-display text-headline-md mt-3 leading-tight">{title}</h3>
      <p className="text-label mt-3 opacity-90">{body}</p>
    </div>
  );
}