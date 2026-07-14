import { useEffect, useState } from "react";
import { Reports } from "../api/client.js";
import { ErrorState, Skeleton } from "../components/Feedback.jsx";

const TABS = [
  { id: "top",      label: "Top tutors" },
  { id: "tutors",   label: "Available now" },
  { id: "revenue",  label: "Revenue / month" }
];

const DAYS = [
  { value: 0, label: "Sunday" },
  { value: 1, label: "Monday" },
  { value: 2, label: "Tuesday" },
  { value: 3, label: "Wednesday" },
  { value: 4, label: "Thursday" },
  { value: 5, label: "Friday" },
  { value: 6, label: "Saturday" }
];

export default function ReportsPage() {
  const [tab, setTab] = useState("top");
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState(null);

  // For tutors tab
  const [filter, setFilter] = useState({ day_of_week: 1, start_time: "09:00", end_time: "17:00" });

  const load = (active = tab, f = filter) => {
    setLoading(true);
    setErr(null);
    const promise =
      active === "top"     ? Reports.topTutors() :
      active === "revenue" ? Reports.revenue()   :
                             Reports.tutors(f);
    promise
      .then((d) => setRows(d.rows || []))
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(tab, filter); /* eslint-disable-next-line */ }, [tab]);

  return (
    <div className="container-editorial py-12">
      <header className="mb-8">
        <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">/ Reports</div>
        <h1 className="font-display text-display-md mt-3 leading-[0.92]">THE DATA ROOM</h1>
        <p className="text-hazard-muted text-headline-sm mt-3 max-w-readable">
          Three hand-written SQL reports running directly on Postgres. <span className="text-mint">RANK()</span> for top tutors, <span className="text-mint">NOT EXISTS</span> for availability, <span className="text-mint">GROUP BY</span> for revenue.
        </p>
      </header>

      {/* Tabs */}
      <div className="flex flex-wrap gap-2 mb-8">
        {TABS.map((t) => (
          <button
            key={t.id}
            onClick={() => setTab(t.id)}
            className={`pill pill--small focus-ring ${
              tab === t.id ? "bg-mint text-absolute border-0" : "pill--secondary"
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === "tutors" && (
        <form
          onSubmit={(e) => { e.preventDefault(); load("tutors", filter); }}
          className="grid grid-cols-1 md:grid-cols-4 gap-3 mb-8 items-end"
        >
          <div>
            <label className="field-label" htmlFor="dow">Day</label>
            <select
              id="dow"
              className="field-input"
              value={filter.day_of_week}
              onChange={(e) => setFilter({ ...filter, day_of_week: Number(e.target.value) })}
            >
              {DAYS.map((d) => <option key={d.value} value={d.value}>{d.label}</option>)}
            </select>
          </div>
          <div>
            <label className="field-label" htmlFor="from">From</label>
            <input id="from" type="time" className="field-input" value={filter.start_time} onChange={(e) => setFilter({ ...filter, start_time: e.target.value })} />
          </div>
          <div>
            <label className="field-label" htmlFor="to">To</label>
            <input id="to" type="time" className="field-input" value={filter.end_time} onChange={(e) => setFilter({ ...filter, end_time: e.target.value })} />
          </div>
          <button type="submit" className="pill pill--primary focus-ring pill--small">Run query</button>
        </form>
      )}

      {err && <ErrorState message={err} onRetry={() => load(tab, filter)} />}

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 5 }).map((_, i) => <Skeleton key={i} className="h-14" />)}
        </div>
      ) : rows.length === 0 ? (
        <div className="rounded-xl border border-dashed border-hazard-secondary/40 p-10 text-center">
          <p className="font-display text-2xl mb-1">No data</p>
          <p className="text-hazard-secondary text-label">Try a different filter, or seed more bookings.</p>
        </div>
      ) : tab === "top" ? (
        <TopTutorsTable rows={rows} />
      ) : tab === "revenue" ? (
        <RevenueTable rows={rows} />
      ) : (
        <AvailableTutorsTable rows={rows} />
      )}
    </div>
  );
}

function TopTutorsTable({ rows }) {
  return (
    <div className="rounded-xl border border-hazard-white/15 overflow-hidden">
      <table className="w-full text-left">
        <thead className="bg-slate-900 border-b border-hazard-white/10">
          <tr>
            <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">#</th>
            <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Tutor</th>
            <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Subject</th>
            <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Bookings</th>
            <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Avg rating</th>
            <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Lifetime rev</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.tutor_id} className="border-b border-hazard-white/5">
              <td className="px-5 py-4 font-display text-2xl">{r.rnk}</td>
              <td className="px-5 py-4">{r.tutor_name}</td>
              <td className="px-5 py-4 text-hazard-muted">{r.subject || "—"}</td>
              <td className="px-5 py-4 font-display text-2xl">{r.booking_count}</td>
              <td className="px-5 py-4">{Number(r.avg_rating).toFixed(2)}</td>
              <td className="px-5 py-4 text-mint">${Number(r.lifetime_revenue).toFixed(2)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function RevenueTable({ rows }) {
  return (
    <div className="rounded-xl border border-hazard-white/15 overflow-hidden">
      <table className="w-full text-left">
        <thead className="bg-slate-900 border-b border-hazard-white/10">
          <tr>
            <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Month</th>
            <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Tutor</th>
            <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Bookings</th>
            <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Revenue</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r, i) => (
            <tr key={`${r.tutor_id}-${r.month}-${i}`} className="border-b border-hazard-white/5">
              <td className="px-5 py-4 font-display text-2xl">{r.month}</td>
              <td className="px-5 py-4">{r.tutor_name}</td>
              <td className="px-5 py-4">{r.booking_count}</td>
              <td className="px-5 py-4 text-mint">${Number(r.total_revenue).toFixed(2)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function AvailableTutorsTable({ rows }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
      {rows.map((r) => (
        <div key={r.tutor_profile_id} className="tile flex flex-col gap-2">
          <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">{r.subject}</div>
          <div className="font-display text-headline-md">{r.name}</div>
          <div className="text-label text-hazard-muted">{r.headline}</div>
          <div className="mt-auto pt-3 flex justify-between text-tag font-mono uppercase tracking-[0.15em]">
            <span className="text-mint">${Number(r.hourly_rate).toFixed(0)}/hr</span>
            <span className="text-hazard-secondary">{r.day_of_week_name}</span>
          </div>
        </div>
      ))}
    </div>
  );
}