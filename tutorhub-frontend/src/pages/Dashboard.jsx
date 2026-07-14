import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Dashboard } from "../api/client.js";
import { useAuth } from "../context/AuthContext.jsx";
import { EmptyState, ErrorState, Skeleton, StatTile } from "../components/Feedback.jsx";
import { StatusBadge } from "../components/Badges.jsx";

export default function DashboardPage() {
  const { user } = useAuth();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState(null);

  useEffect(() => {
    let alive = true;
    Dashboard.show()
      .then((d) => alive && setData(d))
      .catch((e) => alive && setErr(e.message))
      .finally(() => alive && setLoading(false));
    return () => { alive = false; };
  }, []);

  if (loading) {
    return (
      <div className="container-editorial py-12 space-y-6">
        <Skeleton className="h-16 w-72" />
        <Skeleton className="h-40" />
      </div>
    );
  }

  if (err) return <div className="container-editorial py-12"><ErrorState message={err} /></div>;

  const stats = data?.stats ?? { completed: 0, pending: 0 };
  const upcoming = data?.upcoming_bookings ?? [];

  return (
    <div className="container-editorial py-12">
      {/* Hero */}
      <header className="mb-10">
        <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">/ Dashboard</div>
        <h1 className="font-display text-display-md mt-3 leading-[0.92]">
          HEY, <span className="text-mint">{user?.name?.split(" ")[0]?.toUpperCase()}</span>.
        </h1>
        <p className="text-hazard-muted text-headline-sm mt-4 max-w-readable">
          {user?.role === "tutor"
            ? "Manage your weekly availability, confirm incoming requests, and complete sessions to unlock reviews."
            : "Find tutors, track your bookings, and leave reviews after each completed session."}
        </p>

        <div className="flex flex-wrap gap-3 mt-6">
          {user?.role === "tutor" ? (
            <>
              <Link to="/availability" className="pill pill--primary focus-ring">Manage availability</Link>
              <Link to="/bookings"    className="pill pill--secondary focus-ring">Booking queue</Link>
              <Link to="/reports"     className="pill pill--ultraviolet focus-ring">View reports</Link>
            </>
          ) : (
            <>
              <Link to="/tutors"    className="pill pill--primary focus-ring">Browse tutors</Link>
              <Link to="/bookings"  className="pill pill--secondary focus-ring">My bookings</Link>
              <Link to="/reports"   className="pill pill--ultraviolet focus-ring">Reports</Link>
            </>
          )}
        </div>
      </header>

      {/* Stats */}
      <section className="grid grid-cols-1 md:grid-cols-3 gap-5 mb-10">
        <StatTile kicker="Completed" value={stats.completed} accent="mint" />
        <StatTile kicker="Pending" value={stats.pending} accent="ultraviolet" />
        <StatTile kicker="Role" value={user?.role === "tutor" ? "Tutor" : "Student"} accent="white" />
      </section>

      {/* Upcoming */}
      <section>
        <div className="flex items-center justify-between mb-5 flex-wrap gap-4">
          <h2 className="font-display text-headline-lg">Upcoming</h2>
          <Link to="/bookings" className="pill pill--outline pill--small focus-ring">View all</Link>
        </div>

        {upcoming.length === 0 ? (
          <EmptyState
            title="Nothing on the calendar yet"
            hint={user?.role === "tutor" ? "Publish availability so students can book." : "Browse tutors and book your first session."}
            action={<Link to={user?.role === "tutor" ? "/availability" : "/tutors"} className="pill pill--primary pill--small focus-ring">
              {user?.role === "tutor" ? "Set availability" : "Find a tutor"}
            </Link>}
          />
        ) : (
          <ul className="space-y-3">
            {upcoming.map((b) => (
              <li key={b.id}>
                <Link
                  to={`/bookings/${b.id}`}
                  className="tile flex flex-col md:flex-row md:items-center md:justify-between gap-4 hover:border-mint"
                >
                  <div>
                    <div className="font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">
                      {b.booking_date} · {b.start_time}–{b.end_time}
                    </div>
                    <div className="font-display text-headline-md mt-1">
                      {user?.role === "tutor" ? b.student?.name : b.tutor?.name} · {b.subject || "Session"}
                    </div>
                  </div>
                  <StatusBadge status={b.status} />
                </Link>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}