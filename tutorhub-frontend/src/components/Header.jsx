import { Link, NavLink, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function Header() {
  const { isAuthed, user, logout } = useAuth();
  const location = useLocation();

  const navClass = ({ isActive }) => `nav-link focus-ring ${isActive ? "is-active" : ""}`;

  return (
    <header className="sticky top-0 z-40 bg-canvas/95 backdrop-blur border-b border-hazard-white/10">
      <div className="container-editorial flex items-center justify-between gap-6 h-16">
        <Link to="/" className="flex items-center gap-2.5 focus-ring">
          <span aria-hidden className="w-9 h-9 rounded-md bg-mint text-absolute font-display text-2xl flex items-center justify-center leading-none">T</span>
          <span className="font-display tracking-[0.05em] text-2xl text-hazard-white">TUTORHUB</span>
        </Link>

        <nav className="hidden md:flex items-center gap-7">
          <NavLink to="/tutors" className={navClass}>Find tutors</NavLink>
          {isAuthed && <NavLink to="/dashboard" className={navClass}>Dashboard</NavLink>}
          {isAuthed && <NavLink to="/bookings" className={navClass}>Bookings</NavLink>}
          {isAuthed && user?.role === "tutor" && (
            <NavLink to="/availability" className={navClass}>Availability</NavLink>
          )}
          {isAuthed && (
            <NavLink to="/reports" className={navClass}>Reports</NavLink>
          )}
        </nav>

        <div className="flex items-center gap-3">
          {!isAuthed ? (
            <>
              <Link to="/login" className="nav-link focus-ring">Log in</Link>
              <Link to="/signup" className="pill pill--primary pill--small focus-ring" state={{ from: location.pathname }}>
                Sign up
              </Link>
            </>
          ) : (
            <>
              <div className="hidden md:flex flex-col items-end leading-none gap-1">
                <span className="font-mono uppercase text-meta tracking-[0.18em] text-hazard-secondary">
                  {user.role}
                </span>
                <span className="text-label font-semibold text-hazard-white">{user.name}</span>
              </div>
              <button
                onClick={logout}
                className="pill pill--secondary pill--small focus-ring"
              >
                Log out
              </button>
            </>
          )}
        </div>
      </div>
    </header>
  );
}