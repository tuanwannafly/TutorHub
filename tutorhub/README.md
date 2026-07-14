# TutorHub

> Mini Tutor Booking Platform built with **Ruby on Rails 7** — designed as a portfolio project that maps directly to a Junior Ruby on Rails Developer JD.

A two-sided marketplace where **students** browse tutors and book 1-on-1 sessions, while **tutors** manage their availability, accept bookings, and collect reviews. The Booking Engine demonstrates **OOP service objects, optimistic locking, and DB-level unique indexes** — the same concurrency guarantees you'd build in any production booking system.

## Highlights

- **Hand-rolled authentication** using `has_secure_password` (bcrypt) — no Devise, no magic. Sessions controller + `Authenticatable` concern wired into `ApplicationController`.
- **Booking Engine** = the centerpiece of the project.
  - `BookingService` (PORO service object) orchestrates the entire flow.
  - DB unique index `(tutor_id, time_slot)` + Rails `lock_version` (optimistic locking) makes double-booking **impossible**.
  - Concurrency spec simulates two parallel requests — only one wins.
- **Raw SQL reports** in a dedicated `ReportQuery` class with `EXISTS`, `GROUP BY`, and a window function — explicitly to demonstrate SQL depth beyond ActiveRecord magic.
- **RSpec + RuboCop + GitHub Actions CI** wired up out of the box.
- **Git Flow** workflow: `master` / `develop` / `feature/*` / `release/*` / `hotfix/*`, with version tags `v0.1` → `v1.0`.

## Tech Stack

| Layer | Choice |
|---|---|
| Language | Ruby 3.2.x |
| Framework | Rails 7.1.x |
| DB | PostgreSQL 15+ |
| Asset pipeline | Propshaft + importmap-rails + Hotwire (Turbo + Stimulus) |
| Styling | Plain CSS (hand-written, no framework) |
| Auth | `has_secure_password` + custom `SessionsController` |
| Background jobs | ActiveJob (async adapter, ready for Sidekiq) |
| Tests | RSpec, FactoryBot, Faker, Shoulda-matchers, DatabaseCleaner |
| Lint | RuboCop (rails config) |
| CI | GitHub Actions (RSpec + RuboCop) |
| API namespace | JSON-only `/api/*` endpoints for the React frontend |
| Frontend | React 18 + Vite + TailwindCSS in `../tutorhub-frontend` |

## Frontend (React + Tailwind)

A standalone React 18 / Vite / TailwindCSS application lives in
[`../tutorhub-frontend`](../tutorhub-frontend/README.md). It consumes the
`/api/*` JSON endpoints exposed by this Rails app. The visual language is
inspired by The Verge's 2024 redesign — near-black canvas, jelly-mint
hazard accents, rounded pill-cards, mono-uppercase labels.

```bash
# Terminal 1 — Rails API
bin/rails server         # → http://localhost:3000

# Terminal 2 — React dev server
cd ../tutorhub-frontend
npm install
npm run dev              # → http://localhost:5173
```

The Vite dev server proxies `/api/*` to Rails on `:3000`, so cookies
share an origin and the existing session auth works out of the box.

## Quick Start

**Prerequisites:** Ruby 3.2+, PostgreSQL 15+, Bundler, Node 18+.

```bash
# 1. Install gems
bundle install

# 2. Set up the DB
bin/rails db:create db:migrate db:seed

# 3. Run tests
bundle exec rspec

# 4. Boot the server
bin/rails server
# → http://localhost:3000
```

Demo accounts are created by `db/seeds.rb` (see `docs/SETUP.md` for credentials).

## Architecture Overview

```
                     ┌─────────────┐
                     │   Users     │ (role: student | tutor)
                     └──────┬──────┘
                            │ has_one
                            ▼
                     ┌─────────────┐
                     │TutorProfile │
                     └──────┬──────┘
                            │ has_many
                            ▼
                     ┌─────────────┐         ┌─────────────┐
                     │Availability │         │   Bookings  │◄── has_many :through
                     └─────────────┘         └──────┬──────┘
                                                   │ has_one
                                                   ▼
                                            ┌─────────────┐
                                            │   Reviews   │
                                            └─────────────┘
```

Read [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full ERD and design notes, or [`docs/SETUP.md`](docs/SETUP.md) for environment-specific install steps.

## Project Structure

```
tutorhub/
├── app/
│   ├── controllers/          # HTML: Sessions, Registrations, Bookings, …
│   │   └── api/              # JSON API consumed by the React frontend
│   ├── models/               # User, TutorProfile, Availability, Booking, Review
│   │   └── concerns/         # Authenticatable
│   ├── services/             # BookingService, AvailabilityChecker, ReportQuery
│   ├── views/                # ERB templates + handwritten CSS (HTML UI)
│   └── javascript/           # Stimulus controllers
├── config/                   # Routes (HTML + /api/* JSON namespace), DB, initializers
├── db/
│   ├── migrate/              # 5 migrations
│   └── seeds.rb              # Demo tutors + students
├── docs/                     # ARCHITECTURE, SETUP, ERD (Mermaid)
├── spec/                     # RSpec: models, services, requests
└── TASKS.md                  # Sprint breakdown with hour estimates (JD requirement)

../tutorhub-frontend/         # React 18 + Vite + TailwindCSS frontend
└── src/
    ├── api/                  # fetch wrapper + endpoint helpers
    ├── components/           # Header, Layout, RequireAuth, badges, …
    ├── context/              # AuthContext, ToastContext
    └── pages/                # Home, Login, Signup, Dashboard, Tutors, …
```

## Git Workflow

This repo follows **Git Flow**:

```
master        → production-ready releases
  └── develop → integration branch
        ├── feature/s0-project-setup
        ├── feature/s1-user-auth
        ├── feature/s2-availability
        ├── feature/s3-booking-engine
        ├── feature/s4-reports
        ├── feature/s5-reviews
        └── feature/s6-testing
```

Every sprint ends with a `v0.x` tag on `develop`. v1.0 is the final release on `master`. See [TutorHub-Sprint-Plan.md](../TutorHub-Sprint-Plan.md) for the full plan and the JD-mapping table.

## License

MIT — use this freely in your portfolio.
