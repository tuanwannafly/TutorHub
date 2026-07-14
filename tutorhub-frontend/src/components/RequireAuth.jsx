import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function RequireAuth({ children, role }) {
  const { isAuthed, user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="container-editorial py-16">
        <div className="skeleton h-12 w-48 mb-6" />
        <div className="skeleton h-40 w-full" />
      </div>
    );
  }

  if (!isAuthed) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }

  if (role && user.role !== role) {
    return <Navigate to="/dashboard" replace />;
  }

  return children;
}