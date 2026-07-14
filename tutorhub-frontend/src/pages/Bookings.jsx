import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { Bookings } from "../api/client.js";
import { useAuth } from "../context/AuthContext.jsx";
import { EmptyState, ErrorState, Skeleton } from "../components/Feedback.jsx";
import { StatusBadge } from "../components/Badges.jsx";

const FILTERS = [
  { id: "all",       label: "All" },
  { id: "pending",   label: "Pending" },
  { id: "confirmed", label: "Confirmed" },
  { id: "completed", label: "Completed" },
  { id: "cancelled", label: "Cancelled" }
];

export default function Bookings() {
  const { user } = useAuth();
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState(null);
  const [filter, setFilter] = useState("all");

  const load = () => {
    setLoading(true);
    Bookings.list()
      .then(setItems)
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  };
  useEffect(load, []);

  const filtered = useMemo(() => {
    if (filter === "all") return items;
    return items.filter((b) => b.status === filter);
  }, [items, filter]);

  return (
    <div className="container-editorial py-12">
      <header className="mb-8">
        <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">/ Bookings</div>
        <h1 className="font-display text-display-md mt-3 leading-[0.92]">
          {user?.role === "tutor" ? "YOUR QUEUE" : "MY BOOKINGS"}
        </h1>
        <p className="text-hazard-muted text-headline-sm mt-3 max-w-readable">
          {user?.role === "tutor"
            ? "Pending requests need a confirm or cancel; confirmed sessions can be marked complete."
            : "Track upcoming sessions and review completed ones."}
        </p>
      </header>

      {/* Filter pills */}
      <div className="flex flex-wrap gap-2 mb-8">
        {FILTERS.map((f) => (
          <button
            key={f.id}
            onClick={() => setFilter(f.id)}
            className={`pill pill--small focus-ring ${
              filter === f.id
                ? "bg-mint text-absolute border-0"
                : "pill--secondary"
            }`}
          >
            {f.label}
          </button>
        ))}
      </div>

      {err && <ErrorState message={err} onRetry={load} />}

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-20" />)}
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState
          title="Nothing here yet"
          hint={user?.role === "tutor" ? "Once students book you, requests show up here." : "Browse the directory and book a session."}
          action={<Link to="/tutors" className="pill pill--primary pill--small focus-ring">Browse tutors</Link>}
        />
      ) : (
        <div className="rounded-xl border border-hazard-white/15 overflow-hidden">
          <table className="w-full text-left">
            <thead className="bg-slate-900 border-b border-hazard-white/10">
              <tr>
                <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Date</th>
                <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Time</th>
                <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">{user?.role === "tutor" ? "Student" : "Tutor"}</th>
                <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Subject</th>
                <th className="px-5 py-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Status</th>
                <th className="px-5 py-3" />
              </tr>
            </thead>
            <tbody>
              {filtered.map((b) => (
                <tr key={b.id} className="border-b border-hazard-white/5 hover:bg-slate-900/60 transition-colors">
                  <td className="px-5 py-4 font-mono uppercase text-tag tracking-[0.15em]">
                    {b.booking_date}
                  </td>
                  <td className="px-5 py-4 font-display text-2xl">
                    {b.start_time}<span className="text-hazard-secondary"> – </span>{b.end_time}
                  </td>
                  <td className="px-5 py-4">
                    {user?.role === "tutor" ? b.student?.name : b.tutor?.name}
                  </td>
                  <td className="px-5 py-4 text-hazard-muted">{b.subject || "—"}</td>
                  <td className="px-5 py-4"><StatusBadge status={b.status} /></td>
                  <td className="px-5 py-4 text-right">
                    <Link to={`/bookings/${b.id}`} className="pill pill--secondary pill--small focus-ring">View</Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}