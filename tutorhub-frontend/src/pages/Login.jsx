import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";
import { useToast } from "../context/ToastContext.jsx";

export default function Login() {
  const [email, setEmail]       = useState("");
  const [password, setPassword] = useState("");
  const [submitting, setSubmit] = useState(false);
  const [errors, setErrors]     = useState({});
  const { login }  = useAuth();
  const toast = useToast();
  const navigate = useNavigate();
  const location = useLocation();
  const dest = location.state?.from || "/dashboard";

  const onSubmit = async (e) => {
    e.preventDefault();
    setErrors({});
    setSubmit(true);
    try {
      await login(email, password);
      toast.success("Signed in.");
      navigate(dest, { replace: true });
    } catch (err) {
      setErrors({ form: err.message });
    } finally {
      setSubmit(false);
    }
  };

  return (
    <section className="container-editorial py-16">
      <div className="grid lg:grid-cols-2 gap-10 items-center">
        {/* Hero half */}
        <div className="hidden lg:block">
          <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">
            / Welcome back
          </div>
          <h1 className="font-display text-display-md mt-3 leading-[0.92]">
            PICK UP <span className="text-mint">WHERE</span> YOU LEFT OFF.
          </h1>
          <p className="text-hazard-muted text-headline-sm mt-6 max-w-md">
            Sign in to manage your bookings, your availability, or your tutoring queue.
          </p>

          <div className="mt-10 flex flex-wrap gap-3">
            <span className="pill pill--outline pill--small">Students</span>
            <span className="pill pill--outline pill--small">Tutors</span>
            <span className="pill pill--outline pill--small">Reports</span>
          </div>
        </div>

        {/* Form half */}
        <div className="rounded-xl bg-canvas border border-hazard-white/15 p-8 max-w-narrow mx-auto w-full">
          <div className="font-mono uppercase text-tag tracking-[0.15em] text-hazard-secondary">
            Sign in
          </div>
          <h2 className="font-display text-headline-lg mt-2">Your account</h2>

          {errors.form && (
            <div role="alert" className="mt-5 rounded-md border border-ultraviolet bg-ultraviolet/15 px-3 py-2 text-label text-white">
              {errors.form}
            </div>
          )}

          <form onSubmit={onSubmit} className="mt-6 space-y-5">
            <div>
              <label className="field-label" htmlFor="email">Email</label>
              <input
                id="email"
                type="email"
                className="field-input"
                autoComplete="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div>
              <label className="field-label" htmlFor="password">Password</label>
              <input
                id="password"
                type="password"
                className="field-input"
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            <button type="submit" disabled={submitting} className="pill pill--primary w-full focus-ring disabled:opacity-50">
              {submitting ? "Signing in…" : "Sign in"}
            </button>
          </form>

          <p className="mt-6 text-center text-label text-hazard-secondary">
            New here?{" "}
            <Link to="/signup" className="text-mint hover:text-link">Create an account</Link>
          </p>

          <div className="mt-8 border-t border-hazard-white/10 pt-5 text-meta font-mono uppercase tracking-[0.18em] text-hazard-secondary">
            <div className="mb-1">Demo accounts</div>
            <div>alice@tutorhub.dev · password123 (tutor)</div>
            <div>student1@tutorhub.dev · password123 (student)</div>
          </div>
        </div>
      </div>
    </section>
  );
}