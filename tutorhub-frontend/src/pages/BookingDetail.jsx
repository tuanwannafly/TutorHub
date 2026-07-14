import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { Bookings, Reviews } from "../api/client.js";
import { useAuth } from "../context/AuthContext.jsx";
import { useToast } from "../context/ToastContext.jsx";
import { EmptyState, ErrorState, Skeleton } from "../components/Feedback.jsx";
import { StatusBadge } from "../components/Badges.jsx";

export default function BookingDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const toast = useToast();

  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState(null);
  const [busy, setBusy] = useState(false);

  // Review form state
  const [rating, setRating]   = useState(5);
  const [comment, setComment] = useState("");

  const load = () => {
    setLoading(true);
    Bookings.get(id)
      .then(setBooking)
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  };
  useEffect(load, [id]);

  const isTutor     = user?.id === booking?.tutor_id;
  const isStudent   = user?.id === booking?.student_id;
  const isParticipant = isTutor || isStudent;

  const transition = async (fn, msg) => {
    setBusy(true);
    try {
      const updated = await fn();
      setBooking(updated);
      toast.success(msg);
    } catch (e) {
      toast.error(e.message);
    } finally {
      setBusy(false);
    }
  };

  const submitReview = async (e) => {
    e.preventDefault();
    setBusy(true);
    try {
      await Reviews.create(booking.id, { rating: Number(rating), comment });
      toast.success("Thanks for your review!");
      navigate(`/bookings/${booking.id}`);
      load();
    } catch (e) {
      toast.error(e.message);
    } finally {
      setBusy(false);
    }
  };

  if (loading) {
    return <div className="container-editorial py-12"><Skeleton className="h-64" /></div>;
  }
  if (err) return <div className="container-editorial py-12"><ErrorState message={err} onRetry={load} /></div>;
  if (!booking) return null;

  return (
    <div className="container-editorial py-12 max-w-readable">
      <Link to="/bookings" className="nav-link focus-ring inline-block mb-6">← All bookings</Link>

      <div className="rounded-xl border border-hazard-white/15 p-8 mb-6">
        <div className="flex items-start justify-between gap-4 flex-wrap mb-6">
          <div>
            <div className="font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">Booking #{booking.id}</div>
            <h1 className="font-display text-display-md mt-2 leading-[0.95]">
              {booking.subject || "Tutoring session"}
            </h1>
          </div>
          <StatusBadge status={booking.status} />
        </div>

        <dl className="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-3 mb-6">
          <Pair label="Student" value={`${booking.student?.name} (${booking.student?.email})`} />
          <Pair label="Tutor"   value={`${booking.tutor?.name} (${booking.tutor?.email})`} />
          <Pair label="Date"    value={booking.booking_date} />
          <Pair label="Time"    value={`${booking.start_time} – ${booking.end_time}`} />
          <Pair label="Length"  value={`${booking.length_minutes} minutes`} />
          <Pair label="Total"   value={`$${Number(booking.total_amount).toFixed(2)}`} />
        </dl>

        {isParticipant && (
          <div className="flex flex-wrap gap-3 border-t border-hazard-white/10 pt-5">
            {booking.status === "pending" && isTutor && (
              <button
                onClick={() => transition(() => Bookings.confirm(booking.id), "Booking confirmed.")}
                disabled={busy}
                className="pill pill--primary focus-ring pill--small disabled:opacity-50"
              >
                Confirm
              </button>
            )}
            {booking.status === "confirmed" && isTutor && (
              <button
                onClick={() => transition(() => Bookings.complete(booking.id), "Marked complete.")}
                disabled={busy}
                className="pill pill--primary focus-ring pill--small disabled:opacity-50"
              >
                Mark complete
              </button>
            )}
            {(booking.status === "pending" || booking.status === "confirmed") && (
              <button
                onClick={() => transition(() => Bookings.cancel(booking.id), "Booking cancelled.")}
                disabled={busy}
                className="pill pill--danger focus-ring pill--small disabled:opacity-50"
              >
                Cancel
              </button>
            )}
          </div>
        )}
      </div>

      {/* Review block */}
      {booking.review ? (
        <div className="rounded-xl border border-mint/40 bg-mint/10 p-6 mb-6">
          <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">/ Review</div>
          <div className="font-display text-3xl mt-2 text-mint">
            {"★".repeat(booking.review.rating)}<span className="text-hazard-secondary">{"☆".repeat(5 - booking.review.rating)}</span>
          </div>
          <p className="text-hazard-muted mt-3">{booking.review.comment || <em>(no comment)</em>}</p>
        </div>
      ) : booking.status === "completed" && isStudent ? (
        <form onSubmit={submitReview} className="rounded-xl border border-mint p-6 mb-6">
          <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint mb-2">/ Leave a review</div>
          <h3 className="font-display text-headline-md mb-4">How was the session?</h3>

          <div className="mb-4">
            <label className="field-label">Rating</label>
            <div className="flex gap-2">
              {[1, 2, 3, 4, 5].map((n) => (
                <button
                  key={n}
                  type="button"
                  onClick={() => setRating(n)}
                  className={`w-12 h-12 rounded-full font-display text-2xl border ${
                    rating >= n ? "bg-mint text-absolute border-mint" : "border-hazard-white/30 text-hazard-secondary"
                  }`}
                >
                  ★
                </button>
              ))}
            </div>
          </div>

          <div className="mb-4">
            <label className="field-label" htmlFor="comment">Comment (optional)</label>
            <textarea
              id="comment"
              rows={4}
              className="field-input resize-y"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder="Tell other students what to expect..."
            />
          </div>

          <button type="submit" disabled={busy} className="pill pill--primary focus-ring pill--small disabled:opacity-50">
            {busy ? "Submitting…" : "Submit review"}
          </button>
        </form>
      ) : null}
    </div>
  );
}

function Pair({ label, value }) {
  return (
    <div>
      <dt className="font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">{label}</dt>
      <dd className="text-label text-hazard-white mt-1">{value}</dd>
    </div>
  );
}