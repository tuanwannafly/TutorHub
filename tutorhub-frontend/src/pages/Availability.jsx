import { useEffect, useMemo, useState } from "react";
import { Availabilities } from "../api/client.js";
import { useToast } from "../context/ToastContext.jsx";
import { EmptyState, ErrorState, Skeleton } from "../components/Feedback.jsx";

const DAYS = [
  { value: 0, label: "Sunday" },
  { value: 1, label: "Monday" },
  { value: 2, label: "Tuesday" },
  { value: 3, label: "Wednesday" },
  { value: 4, label: "Thursday" },
  { value: 5, label: "Friday" },
  { value: 6, label: "Saturday" }
];

export default function AvailabilityPage() {
  const toast = useToast();
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState(null);
  const [form, setForm] = useState({ day_of_week: "", start_time: "", end_time: "" });
  const [busy, setBusy] = useState(false);

  const load = () => {
    setLoading(true);
    Availabilities.list()
      .then((d) => setItems(d.availabilities || []))
      .catch((e) => setErr(e.message))
      .finally(() => setLoading(false));
  };
  useEffect(load, []);

  const grouped = useMemo(() => {
    const map = {};
    items.forEach((a) => {
      (map[a.day_of_week] ||= []).push(a);
    });
    return DAYS.map((d) => ({ ...d, windows: map[d.value] || [] }));
  }, [items]);

  const addWindow = async (e) => {
    e.preventDefault();
    setBusy(true);
    try {
      await Availabilities.create({
        day_of_week: Number(form.day_of_week),
        start_time: form.start_time,
        end_time: form.end_time
      });
      setForm({ day_of_week: "", start_time: "", end_time: "" });
      toast.success("Availability added.");
      load();
    } catch (e) {
      toast.error(e.message);
    } finally {
      setBusy(false);
    }
  };

  const removeWindow = async (id) => {
    setBusy(true);
    try {
      await Availabilities.remove(id);
      toast.success("Removed.");
      load();
    } catch (e) {
      toast.error(e.message);
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="container-editorial py-12">
      <header className="mb-8">
        <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">/ Availability</div>
        <h1 className="font-display text-display-md mt-3 leading-[0.92]">YOUR WEEK</h1>
        <p className="text-hazard-muted text-headline-sm mt-3 max-w-readable">
          Define the windows when students can book you. Slots must not overlap on the same day.
        </p>
      </header>

      <form onSubmit={addWindow} className="rounded-xl border border-mint/40 bg-mint/5 p-6 mb-10">
        <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint mb-4">/ Add a window</div>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
          <div>
            <label className="field-label" htmlFor="day_of_week">Day</label>
            <select
              id="day_of_week"
              required
              className="field-input"
              value={form.day_of_week}
              onChange={(e) => setForm({ ...form, day_of_week: e.target.value })}
            >
              <option value="">Pick a day</option>
              {DAYS.map((d) => <option key={d.value} value={d.value}>{d.label}</option>)}
            </select>
          </div>
          <div>
            <label className="field-label" htmlFor="start_time">Start</label>
            <input
              id="start_time" type="time" required
              className="field-input"
              value={form.start_time}
              onChange={(e) => setForm({ ...form, start_time: e.target.value })}
            />
          </div>
          <div>
            <label className="field-label" htmlFor="end_time">End</label>
            <input
              id="end_time" type="time" required
              className="field-input"
              value={form.end_time}
              onChange={(e) => setForm({ ...form, end_time: e.target.value })}
            />
          </div>
          <button type="submit" disabled={busy} className="pill pill--primary focus-ring disabled:opacity-50">
            {busy ? "Adding…" : "Add window"}
          </button>
        </div>
      </form>

      {err && <ErrorState message={err} onRetry={load} />}

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => <Skeleton key={i} className="h-16" />)}
        </div>
      ) : items.length === 0 ? (
        <EmptyState title="No availability yet" hint="Add a window above so students can book you." />
      ) : (
        <div className="space-y-5">
          {grouped.filter((g) => g.windows.length).map((g) => (
            <div key={g.value} className="rounded-xl bg-canvas border border-hazard-white/15 p-5">
              <div className="flex items-center justify-between mb-3">
                <h3 className="font-display text-headline-md">{g.label}</h3>
                <span className="font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">
                  {g.windows.length} {g.windows.length === 1 ? "window" : "windows"}
                </span>
              </div>
              <ul className="divide-y divide-hazard-white/10">
                {g.windows.map((w) => (
                  <li key={w.id} className="flex items-center justify-between py-3">
                    <div>
                      <span className="font-display text-2xl">{w.start_time}</span>
                      <span className="text-hazard-secondary mx-2">→</span>
                      <span className="font-display text-2xl">{w.end_time}</span>
                      <span className="ml-3 font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">
                        {w.length_minutes} min
                      </span>
                    </div>
                    <button
                      onClick={() => removeWindow(w.id)}
                      disabled={busy}
                      className="pill pill--danger pill--small focus-ring disabled:opacity-50"
                    >
                      Remove
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}