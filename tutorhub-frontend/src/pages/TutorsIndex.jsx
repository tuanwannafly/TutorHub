import { useEffect, useMemo, useState } from "react";
import { Link, useSearchParams } from "react-router-dom";
import { Tutors } from "../api/client.js";
import { EmptyState, ErrorState, Skeleton } from "../components/Feedback.jsx";

export default function TutorsIndex() {
  const [params, setParams] = useSearchParams();
  const [data, setData] = useState({ tutors: [], meta: { page: 1, total_pages: 1 } });
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState(null);

  const query = params.get("query") || "";
  const page  = Number(params.get("page") || 1);

  useEffect(() => {
    let alive = true;
    setLoading(true);
    Tutors.list({ query, page })
      .then((d) => alive && setData(d))
      .catch((e) => alive && setErr(e.message))
      .finally(() => alive && setLoading(false));
    return () => { alive = false; };
  }, [query, page]);

  const onSearch = (e) => {
    e.preventDefault();
    const q = new FormData(e.currentTarget).get("query") || "";
    const next = new URLSearchParams(params);
    if (q) next.set("query", q); else next.delete("query");
    next.set("page", "1");
    setParams(next);
  };

  const setPage = (n) => {
    const next = new URLSearchParams(params);
    next.set("page", String(n));
    setParams(next);
  };

  const accents = ["tile-accent-mint", "tile-accent-ultraviolet", "tile-accent-white", ""];

  return (
    <div className="container-editorial py-12">
      {/* ── Header strip ─────────────────────────────────────── */}
      <header className="flex flex-col md:flex-row md:items-end md:justify-between gap-6 mb-10">
        <div>
          <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">/ Directory</div>
          <h1 className="font-display text-display-md mt-3 leading-[0.92]">
            FIND A <span className="text-mint">TUTOR</span>
          </h1>
          <p className="text-hazard-muted text-headline-sm mt-3 max-w-readable">
            Search by subject, headline, bio or email. Page through the catalogue, then book a slot.
          </p>
        </div>

        <form onSubmit={onSearch} className="flex items-center gap-2 w-full md:max-w-sm">
          <label htmlFor="q" className="sr-only">Search</label>
          <input
            id="q"
            name="query"
            defaultValue={query}
            placeholder="e.g. Calculus, IELTS, Ruby"
            className="field-input"
            type="search"
          />
          <button type="submit" className="pill pill--primary focus-ring pill--small">Search</button>
        </form>
      </header>

      {err && <ErrorState message={err} onRetry={() => setParams(params)} />}

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {Array.from({ length: 9 }).map((_, i) => <Skeleton key={i} className="h-48" />)}
        </div>
      ) : data.tutors.length === 0 ? (
        <EmptyState
          title="No tutors match that search"
          hint="Try clearing the filter or searching for a broader term."
          action={<Link to="/tutors" className="pill pill--outline pill--small focus-ring">Reset</Link>}
        />
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {data.tutors.map((t, idx) => {
              const accent = accents[idx % accents.length];
              return (
                <Link
                  key={t.id}
                  to={`/tutors/${t.id}`}
                  className={`tile ${accent} flex flex-col gap-3 hover:translate-y-[-2px] transition-transform`}
                >
                  <div className="flex items-center justify-between">
                    <span className="font-mono uppercase text-meta tracking-[0.18em] opacity-80">{t.subject || "General"}</span>
                    <span className="font-mono uppercase text-meta tracking-[0.18em] opacity-80">${Number(t.hourly_rate).toFixed(0)}/hr</span>
                  </div>
                  <div className="font-display text-headline-md leading-tight">{t.user?.name}</div>
                  <p className="text-label opacity-90 line-clamp-2">{t.headline || t.bio || "Independent tutor"}</p>
                  <div className="mt-auto pt-3 font-mono uppercase text-meta tracking-[0.18em] opacity-80">
                    View profile →
                  </div>
                </Link>
              );
            })}
          </div>

          {data.meta.total_pages > 1 && (
            <nav className="mt-10 flex items-center justify-center gap-6">
              <button
                onClick={() => setPage(Math.max(1, page - 1))}
                disabled={page <= 1}
                className="pill pill--secondary pill--small disabled:opacity-40"
              >
                ← Prev
              </button>
              <span className="font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">
                Page {data.meta.page} / {data.meta.total_pages}
              </span>
              <button
                onClick={() => setPage(Math.min(data.meta.total_pages, page + 1))}
                disabled={page >= data.meta.total_pages}
                className="pill pill--secondary pill--small disabled:opacity-40"
              >
                Next →
              </button>
            </nav>
          )}
        </>
      )}
    </div>
  );
}