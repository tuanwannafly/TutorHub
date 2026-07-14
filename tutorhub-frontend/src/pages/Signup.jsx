import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";
import { useToast } from "../context/ToastContext.jsx";

export default function Signup() {
  const navigate = useNavigate();
  const { signup } = useAuth();
  const toast = useToast();

  const [form, setForm] = useState({
    name: "",
    email: "",
    password: "",
    password_confirmation: "",
    role: "student"
  });
  const [tutorProfile, setTutorProfile] = useState({
    subject: "",
    headline: "",
    hourly_rate: 25,
    bio: ""
  });
  const [submitting, setSubmit] = useState(false);
  const [errors, setErrors] = useState({});

  const update = (k) => (e) => setForm({ ...form, [k]: e.target.value });
  const updateTp = (k) => (e) => setTutorProfile({ ...tutorProfile, [k]: e.target.value });

  const onSubmit = async (e) => {
    e.preventDefault();
    setErrors({});
    setSubmit(true);
    try {
      const attrs = { ...form };
      if (form.role === "tutor") {
        attrs.tutor_profile_attributes = {
          ...tutorProfile,
          hourly_rate: Number(tutorProfile.hourly_rate) || 0
        };
      }
      await signup(attrs);
      toast.success("Welcome to TutorHub.");
      navigate("/dashboard", { replace: true });
    } catch (err) {
      if (err.details) setErrors(err.details);
      else setErrors({ form: err.message });
    } finally {
      setSubmit(false);
    }
  };

  const fieldErr = (name) => errors[name]?.[0];

  return (
    <section className="container-editorial py-12">
      <div className="grid lg:grid-cols-2 gap-10 items-start">
        <div className="lg:sticky lg:top-24">
          <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint">/ Create account</div>
          <h1 className="font-display text-display-md mt-3 leading-[0.92]">
            PICK YOUR <span className="text-mint">LANE.</span>
          </h1>
          <p className="text-hazard-muted text-headline-sm mt-5 max-w-md">
            Two roles, one platform. Students book sessions. Tutors publish availability and confirm bookings.
          </p>
          <ul className="mt-8 space-y-3 text-label text-hazard-muted">
            <li className="flex items-start gap-3">
              <span className="pill pill--outline pill--small">Student</span>
              Browse tutors, book slots, leave reviews after the session is completed.
            </li>
            <li className="flex items-start gap-3">
              <span className="pill pill--ultraviolet pill--small">Tutor</span>
              Publish weekly availability, confirm incoming bookings, mark sessions complete.
            </li>
          </ul>
        </div>

        <form onSubmit={onSubmit} className="rounded-xl bg-canvas border border-hazard-white/15 p-8 max-w-narrow w-full mx-auto">
          {errors.form && (
            <div role="alert" className="mb-5 rounded-md border border-ultraviolet bg-ultraviolet/15 px-3 py-2 text-label">
              {errors.form}
            </div>
          )}

          <div className="grid grid-cols-2 gap-2 mb-6 rounded-full bg-slate-900 p-1 border border-hazard-white/10">
            {["student", "tutor"].map((r) => (
              <button
                key={r}
                type="button"
                onClick={() => setForm({ ...form, role: r })}
                className={`pill pill--small border-0 ${
                  form.role === r
                    ? "bg-mint text-absolute"
                    : "bg-transparent text-hazard-secondary"
                }`}
              >
                I want to be a {r}
              </button>
            ))}
          </div>

          <Field label="Full name" htmlFor="name" error={fieldErr("name")}>
            <input id="name" className="field-input" autoComplete="name" value={form.name} onChange={update("name")} required />
          </Field>

          <Field label="Email" htmlFor="email" error={fieldErr("email")}>
            <input id="email" type="email" className="field-input" autoComplete="email" value={form.email} onChange={update("email")} required />
          </Field>

          <div className="grid grid-cols-2 gap-4">
            <Field label="Password" htmlFor="password" error={fieldErr("password")} hint="At least 6 characters">
              <input id="password" type="password" className="field-input" autoComplete="new-password" value={form.password} onChange={update("password")} required />
            </Field>
            <Field label="Confirm" htmlFor="password_confirmation" error={fieldErr("password_confirmation")}>
              <input id="password_confirmation" type="password" className="field-input" autoComplete="new-password" value={form.password_confirmation} onChange={update("password_confirmation")} required />
            </Field>
          </div>

          {form.role === "tutor" && (
            <div className="mt-6 rounded-xl border border-mint/50 bg-mint/5 p-5">
              <div className="font-mono uppercase text-meta tracking-[0.18em] text-mint mb-4">Tutor details</div>
              <Field label="Primary subject" htmlFor="subject" error={fieldErr("tutor_profile.subject")}>
                <input id="subject" className="field-input" value={tutorProfile.subject} onChange={updateTp("subject")} placeholder="e.g. Mathematics" required />
              </Field>
              <Field label="Hourly rate (USD)" htmlFor="hourly_rate" error={fieldErr("tutor_profile.hourly_rate")}>
                <input id="hourly_rate" type="number" min="0" step="0.01" className="field-input" value={tutorProfile.hourly_rate} onChange={updateTp("hourly_rate")} />
              </Field>
              <Field label="Headline" htmlFor="headline" error={fieldErr("tutor_profile.headline")}>
                <input id="headline" className="field-input" value={tutorProfile.headline} onChange={updateTp("headline")} placeholder="One-line pitch (max 100 chars)" />
              </Field>
              <Field label="About you" htmlFor="bio" error={fieldErr("tutor_profile.bio")}>
                <textarea id="bio" rows={4} className="field-input resize-y" value={tutorProfile.bio} onChange={updateTp("bio")} placeholder="Tell students what to expect" />
              </Field>
            </div>
          )}

          <button type="submit" disabled={submitting} className="pill pill--primary w-full mt-6 focus-ring disabled:opacity-50">
            {submitting ? "Creating…" : "Create account"}
          </button>

          <p className="mt-5 text-center text-label text-hazard-secondary">
            Already have an account?{" "}
            <Link to="/login" className="text-mint hover:text-link">Sign in</Link>
          </p>
        </form>
      </div>
    </section>
  );
}

function Field({ label, htmlFor, error, hint, children }) {
  return (
    <div className="mb-4">
      <label className="field-label" htmlFor={htmlFor}>{label}</label>
      {children}
      {error ? <p className="field-error">{error}</p> : hint ? <p className="field-hint">{hint}</p> : null}
    </div>
  );
}