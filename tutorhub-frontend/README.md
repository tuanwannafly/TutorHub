# TutorHub — React Frontend

A React 18 + Vite + Tailwind CSS frontend that fits the TutorHub Rails 7
JSON API. The visual language follows the design tokens in
[`DESIGN-theverge.md`](../../DESIGN-theverge.md) — near-black editorial
canvas, jelly-mint hazard accents, rounded pill-cards, mono-uppercase labels.

## Stack

- React 18 + React Router 6
- Vite (dev server + bundler)
- TailwindCSS 3 (theme tokens matching the design brief)
- Native `fetch` API (no axios, no react-query — keeps the bundle small)
- `date-fns` for date formatting

## Project layout

```
src/
├── api/client.js           # fetch wrapper + endpoint helpers + ApiError
├── components/             # Header, Footer, Layout, RequireAuth, badges
├── context/
│   ├── AuthContext.jsx     # login/signup/logout/me
│   └── ToastContext.jsx    # transient notifications
├── pages/
│   ├── Home.jsx            # Landing page (hero + featured tutors)
│   ├── Login.jsx           # Sign-in
│   ├── Signup.jsx          # Two-step role pick + tutor details
│   ├── Dashboard.jsx       # Role-aware dashboard
│   ├── TutorsIndex.jsx     # Searchable tutor directory
│   ├── TutorProfile.jsx    # Tutor detail + book-this-slot flow
│   ├── Bookings.jsx        # List of my bookings (role-filtered)
│   ├── BookingDetail.jsx   # Single booking + state transitions + review form
│   ├── Availability.jsx    # Tutor-only: manage weekly windows
│   ├── Reports.jsx         # Three raw-SQL reports (top, available, revenue)
│   └── NotFound.jsx
├── App.jsx                 # Router + auth guards
└── main.jsx                # ReactDOM entry
```

## Running locally

### 1. Backend (Rails)

```bash
cd ../tutorhub
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server     # http://localhost:3000
```

### 2. Frontend (React)

```bash
cd tutorhub-frontend
npm install
npm run dev          # http://localhost:5173
```

The Vite dev server proxies `/api/*` to `http://localhost:3000`, so the
React app and the Rails app share the same origin for `/api` and
cookies work out of the box.

### 3. Demo accounts

After seeding (`db/seeds.rb`):

| Role    | Email                  | Password    |
|---------|------------------------|-------------|
| Tutor   | alice@tutorhub.dev     | password123 |
| Tutor   | bob@tutorhub.dev       | password123 |
| Tutor   | carol@tutorhub.dev     | password123 |
| Tutor   | dave@tutorhub.dev      | password123 |
| Student | student1@tutorhub.dev  | password123 |
| Student | student2@tutorhub.dev  | password123 |
| Student | student3@tutorhub.dev  | password123 |

## Design system (TL;DR)

The whole theme lives in `tailwind.config.js`. Three colors do the heavy
lifting:

- `#131313` canvas
- `#3cffd0` jelly mint (primary CTA)
- `#5200ff` verge ultraviolet (secondary)

Component primitives (defined in `src/index.css` via `@layer components`):
`.pill`, `.pill--primary`, `.pill--secondary`, `.pill--outline`,
`.pill--ultraviolet`, `.tile`, `.tile-accent-mint`, `.tile-accent-ultraviolet`,
`.tile-accent-white`, `.badge`, `.badge-pending`, `.badge-confirmed`,
`.badge-completed`, `.badge-cancelled`, `.timeline-rail`, `.timeline-stamp`.

## JSON API

The full backend route list lives in `../tutorhub/config/routes.rb` under
`namespace :api`. Each controller returns:

```json
{ "ok": true,  "data": ... }
{ "ok": false, "error": { "code": "...", "message": "...", "details": {...} } }
```

End-points consumed by the frontend:

| Method | Path                                | Purpose                          |
|--------|-------------------------------------|----------------------------------|
| GET    | /api/session                        | Current user                     |
| POST   | /api/session                        | Login                            |
| DELETE | /api/session                        | Logout                           |
| POST   | /api/signup                         | Register (student/tutor)         |
| GET    | /api/tutors                         | Public directory (paged, search) |
| GET    | /api/tutors/:id                     | Tutor profile + availability     |
| GET    | /api/dashboard                      | Role-aware dashboard             |
| GET    | /api/availabilities                 | Tutor's availability             |
| POST   | /api/availabilities                 | Add a window                     |
| DELETE | /api/availabilities/:id             | Remove a window                  |
| GET    | /api/bookings                       | My bookings                      |
| GET    | /api/bookings/:id                   | Booking detail                   |
| POST   | /api/bookings                       | Request booking                  |
| PATCH  | /api/bookings/:id/confirm           | Tutor confirms                   |
| PATCH  | /api/bookings/:id/cancel            | Cancel                           |
| PATCH  | /api/bookings/:id/complete          | Mark complete                    |
| POST   | /api/bookings/:booking_id/reviews   | Leave a review                   |
| GET    | /api/reports/tutors                 | Available tutors (raw SQL)       |
| GET    | /api/reports/revenue                | Monthly revenue per tutor        |
| GET    | /api/reports/top_tutors             | Top tutors (window function)     |
| GET    | /api/lookups/days_of_week           | UI metadata                      |
| GET    | /api/lookups/roles                  | UI metadata                      |
| GET    | /api/lookups/booking_statuses       | UI metadata                      |

## Build for production

```bash
npm run build      # outputs to dist/
```

Serve `dist/` from any static host (Netlify, Vercel, Render static,
nginx). In production, point the API at the Rails server (same domain or
CORS-enabled origin) and the React bundle will hit it with
`credentials: "include"`.