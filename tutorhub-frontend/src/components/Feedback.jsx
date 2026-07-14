export function EmptyState({ title, hint, action }) {
  return (
    <div className="rounded-xl border border-dashed border-hazard-secondary/40 bg-canvas/40 px-6 py-12 text-center">
      <p className="font-display text-3xl mb-2">{title}</p>
      {hint && <p className="text-hazard-secondary text-label max-w-readable mx-auto">{hint}</p>}
      {action && <div className="mt-5">{action}</div>}
    </div>
  );
}

export function ErrorState({ title = "Something went wrong", message, onRetry }) {
  return (
    <div className="rounded-xl border border-ultraviolet bg-ultraviolet/10 px-6 py-8 text-center">
      <p className="font-display text-2xl mb-1">{title}</p>
      {message && <p className="text-hazard-muted text-label mb-4">{message}</p>}
      {onRetry && (
        <button onClick={onRetry} className="pill pill--outline focus-ring pill--small">Try again</button>
      )}
    </div>
  );
}

export function Skeleton({ className = "" }) {
  return <div className={`skeleton ${className}`} />;
}

export function StatTile({ kicker, value, accent = "mint" }) {
  const accentBg = accent === "mint" ? "bg-mint" :
                   accent === "ultraviolet" ? "bg-ultraviolet" :
                   accent === "white" ? "bg-hazard-white" : "bg-slate-700";
  const accentColor = accentBg === "bg-mint" ? "text-absolute" :
                      accentBg === "bg-hazard-white" ? "text-absolute" :
                      "text-hazard-white";
  return (
    <div className={`rounded-xl p-6 ${accentBg} ${accentColor}`}>
      <div className="font-mono uppercase text-meta tracking-[0.18em] opacity-80">{kicker}</div>
      <div className="font-display text-display-md mt-3 leading-none">{value}</div>
    </div>
  );
}