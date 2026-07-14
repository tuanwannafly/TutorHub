// Single fetch wrapper that talks to the Rails JSON API.
//
// Returns the parsed `data` payload on success. On failure, throws an
// `ApiError` with `{ status, code, message, details }` so React components
// can show a flash/toast without needing to know the envelope shape.

export class ApiError extends Error {
  constructor({ status, code, message, details }) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

function csrfToken() {
  const match = document.cookie.match(/CSRF-TOKEN=([^;]+)/);
  return match ? decodeURIComponent(match[1]) : null;
}

async function request(path, { method = "GET", body, headers = {} } = {}) {
  const opts = {
    method,
    credentials: "include",
    headers: {
      Accept: "application/json",
      ...headers
    }
  };

  if (body !== undefined) {
    opts.headers["Content-Type"] = "application/json";
    const token = csrfToken();
    if (token) opts.headers["X-CSRF-Token"] = token;
    opts.body = JSON.stringify(body);
  } else if (method !== "GET") {
    const token = csrfToken();
    if (token) opts.headers["X-CSRF-Token"] = token;
  }

  const res = await fetch(path, opts);

  // Some endpoints return 204 — treat as success.
  if (res.status === 204) return null;

  const payload = await res.json().catch(() => ({}));

  if (!res.ok || payload.ok === false) {
    const err = payload?.error ?? {};
    throw new ApiError({
      status: res.status,
      code: err.code ?? "unknown",
      message: err.message ?? `Request failed (${res.status})`,
      details: err.details
    });
  }

  return payload.data;
}

export const api = {
  get:  (path)         => request(path),
  post: (path, body)   => request(path, { method: "POST", body }),
  patch: (path, body)  => request(path, { method: "PATCH", body }),
  put: (path, body)    => request(path, { method: "PUT", body }),
  del:  (path)         => request(path, { method: "DELETE" })
};

// ── Domain helpers ────────────────────────────────────────────────
export const Auth = {
  me:        ()       => api.get("/api/session"),
  login:     (email, password) => api.post("/api/session", { email, password }),
  signup:    (attrs)   => api.post("/api/signup", { user: attrs }),
  logout:    ()        => api.del("/api/session")
};

export const Tutors = {
  list:  (params = {}) => {
    const qs = new URLSearchParams(params).toString();
    return api.get(`/api/tutors${qs ? `?${qs}` : ""}`);
  },
  get:   (id)    => api.get(`/api/tutors/${id}`)
};

export const Availabilities = {
  list:    ()    => api.get("/api/availabilities"),
  create:  (a)   => api.post("/api/availabilities", { availability: a }),
  remove:  (id)  => api.del(`/api/availabilities/${id}`)
};

export const Bookings = {
  list:    ()      => api.get("/api/bookings"),
  get:     (id)    => api.get(`/api/bookings/${id}`),
  create:  (b)     => api.post("/api/bookings", b),
  confirm: (id)    => api.patch(`/api/bookings/${id}/confirm`),
  cancel:  (id)    => api.patch(`/api/bookings/${id}/cancel`),
  complete:(id)    => api.patch(`/api/bookings/${id}/complete`)
};

export const Reviews = {
  create: (bookingId, r) => api.post(`/api/bookings/${bookingId}/reviews`, { review: r }),
  get:    (id)           => api.get(`/api/reviews/${id}`)
};

export const Dashboard = {
  show: () => api.get("/api/dashboard")
};

export const Reports = {
  tutors:    (params) => {
    const qs = new URLSearchParams(params).toString();
    return api.get(`/api/reports/tutors${qs ? `?${qs}` : ""}`);
  },
  revenue:   ()  => api.get("/api/reports/revenue"),
  topTutors: ()  => api.get("/api/reports/top_tutors")
};

export const Lookups = {
  daysOfWeek:     () => api.get("/api/lookups/days_of_week"),
  roles:          () => api.get("/api/lookups/roles"),
  bookingStatuses:() => api.get("/api/lookups/booking_statuses")
};