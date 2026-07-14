import { createContext, useCallback, useContext, useMemo, useState } from "react";

const ToastContext = createContext(null);

export function ToastProvider({ children }) {
  const [toasts, setToasts] = useState([]);

  const push = useCallback((toast) => {
    const id = Math.random().toString(36).slice(2);
    setToasts((cur) => [...cur, { id, ...toast }]);
    setTimeout(() => setToasts((cur) => cur.filter((t) => t.id !== id)), toast.duration ?? 4500);
  }, []);

  const api = useMemo(() => ({
    success: (message) => push({ kind: "success", message }),
    error:   (message) => push({ kind: "error",   message }),
    info:    (message) => push({ kind: "info",    message }),
    notice:  (message) => push({ kind: "notice",  message }),
    push
  }), [push]);

  return (
    <ToastContext.Provider value={api}>
      {children}
      <div className="fixed z-50 top-6 right-6 flex flex-col gap-3 max-w-sm w-full">
        {toasts.map((t) => (
          <div
            key={t.id}
            role="status"
            className={[
              "rounded-xl px-4 py-3 font-mono uppercase text-tag tracking-[0.18em] border animate-fade-in",
              t.kind === "error"   ? "bg-ultraviolet/20 border-ultraviolet text-white" :
              t.kind === "success" ? "bg-mint/15 border-mint text-mint" :
              t.kind === "notice"  ? "bg-white/10 border-white/30 text-white" :
                                     "bg-canvas border-hazard-secondary/40 text-hazard-muted"
            ].join(" ")}
          >
            {t.message}
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export function useToast() {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error("useToast must be used within ToastProvider");
  return ctx;
}