import { createContext, useContext, useEffect, useMemo, useState, useCallback } from "react";
import { Auth } from "../api/client.js";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    try {
      const data = await Auth.me();
      setUser(data || null);
    } catch (err) {
      setUser(null);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { refresh(); }, [refresh]);

  const login  = useCallback(async (email, password) => {
    const data = await Auth.login(email, password);
    setUser(data);
    return data;
  }, []);

  const signup = useCallback(async (attrs) => {
    const data = await Auth.signup(attrs);
    setUser(data);
    return data;
  }, []);

  const logout = useCallback(async () => {
    try { await Auth.logout(); } finally { setUser(null); }
  }, []);

  const value = useMemo(() => ({
    user,
    loading,
    isAuthed: !!user,
    isStudent: user?.role === "student",
    isTutor:   user?.role === "tutor",
    login,
    signup,
    logout,
    refresh
  }), [user, loading, login, signup, logout, refresh]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}