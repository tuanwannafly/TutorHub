# TASKS — TutorHub Sprint Breakdown & Estimates

> This document is the **"estimate tasks"** deliverable that the JD asks for. Hour estimates are realistic for a working developer — not a polished fiction.

**Calendar days allocated:** ~8 working days (10 if Sprint 4 deploy runs long)
**Total estimate:** ~62 hours

---

## Sprint 0 — Setup & Planning (~4h)

| # | Task | Estimate | Status |
|---|---|---|---|
| 0.1 | `rails new tutorhub -d postgresql --css=tailwind` (with --skip-* flags tuned) | 0.5h | done |
| 0.2 | Strip Tailwind, fold in our hand-written CSS reset | 0.5h | done |
| 0.3 | `.gitignore`, RSpec + FactoryBot + Faker install | 1.0h | done |
| 0.4 | RuboCop `rails` config + default style + Gemspec | 0.5h | done |
| 0.5 | ERD (Mermaid) in `docs/ARCHITECTURE.md` | 1.0h | done |
| 0.6 | This `TASKS.md` | 0.5h | done |

**Definition of Done:** Rails app boots, DB connects, `bundle exec rspec` exits 0.

---

## Sprint 1 — Authentication & Core Models (~10h)

| # | Task | Estimate | Status |
|---|---|---|---|
| 1.1 | Migration `users` (email, password_digest, role enum) | 0.5h | done |
| 1.2 | `User` model with `has_secure_password`, validations, normalizers | 1.5h | done |
| 1.3 | Migration `tutor_profiles` (subject, hourly_rate, bio) | 0.5h | done |
| 1.4 | `TutorProfile` model + `has_one` association | 1.0h | done |
| 1.5 | `Authenticatable` concern → `current_user`, `require_login` | 1.0h | done |
| 1.6 | `SessionsController` (new/create/destroy) | 1.5h | done |
| 1.7 | `RegistrationsController` (new/create) with role select | 1.5h | done |
| 1.8 | Views: login, signup, logout (handwritten form styling) | 1.5h | done |
| 1.9 | RSpec model specs (User, TutorProfile) | 1.0h | done |

**Definition of Done:** Sign up as student AND tutor, log in, log out, all green.

---

## Sprint 2 — Availability & Booking Engine (~22h)

> This is the **centerpiece of the project** — JD aligns directly with the OOP + SQL + concurrency focus.

| # | Task | Estimate | Status |
|---|---|---|---|
| 2.1 | Migration `availabilities` (tutor_profile_id, day_of_week, start_time, end_time) | 0.5h | done |
| 2.2 | `Availability` model with overlap validation | 1.5h | done |
| 2.3 | `has_many :through` Student ↔ Tutor via Bookings | 1.0h | done |
| 2.4 | `AvailabilityChecker` PORO — slot-vs-avail logic, unit-tested | 2.5h | done |
| 2.5 | Tutor-side UI: manage own availability slots | 3.0h | done |
| 2.6 | Migration `bookings` with status enum + `lock_version` + composite unique index | 0.5h | done |
| 2.7 | `Booking` model + state-machine methods (`pending?`, `confirm!`, `complete!`, `cancel!`) | 2.0h | done |
| 2.8 | `BookingService` PORO — full orchestration, `BookingConflictError` | 3.0h | done |
| 2.9 | Concurrency spec — 2 parallel bookings, only 1 succeeds (using threads + DB) | 2.0h | done |
| 2.10 | `BookingsController` — student book / tutor confirm / cancel | 2.5h | done |
| 2.11 | Views: student slot-picker, tutor booking queue | 3.0h | done |

**Definition of Done:** Concurrency test passes, full flow works.

---

## Sprint 3 — SQL Reports & Reviews (~10h)

| # | Task | Estimate | Status |
|---|---|---|---|
| 3.1 | `ReportQuery` class — Query #1 (tutor-search by availability) with `EXISTS` SQL | 2.0h | done |
| 3.2 | ReportQuery — Query #2 (revenue per tutor, monthly, `JOIN` + `GROUP BY`) | 1.5h | done |
| 3.3 | ReportQuery — Query #3 (top tutors, window function `RANK() OVER`) | 1.5h | done |
| 3.4 | Admin dashboard view (role-gated) for the 3 reports | 1.5h | done |
| 3.5 | Migration `reviews` (booking_id, rating, comment) | 0.5h | done |
| 3.6 | `Review` model with rating range + uniqueness per booking | 1.0h | done |
| 3.7 | `ReviewsController` + views, gated on booking `completed?` | 2.0h | done |

**Definition of Done:** 3 raw SQL queries return verified results; review flow works.

---

## Sprint 4 — Testing, Polish & Deploy (~16h)

| # | Task | Estimate | Status |
|---|---|---|---|
| 4.1 | RSpec request specs (happy + conflict paths for booking flow) | 2.5h | done |
| 4.2 | RSpec review specs (rating bounds, one-per-booking) | 1.0h | done |
| 4.3 | CSS polish — responsive grid, dashboard layout | 2.5h | done |
| 4.4 | `db/seeds.rb` — 4 tutors, 3 students, sample availability + bookings | 1.5h | done |
| 4.5 | README expansion (architecture diagram links, demo credentials) | 1.0h | done |
| 4.6 | GitHub Actions CI — RSpec + RuboCop matrix (Ruby 3.2, Postgres 15) | 2.0h | done |
| 4.7 | Render `render.yaml` + Dockerfile (production-ready) | 2.5h | done |
| 4.8 | Final smoke test on live URL + tag `v1.0` | 3.0h | done |

**Definition of Done:** CI green on main, README reproducible, deploy reachable.

---

## JD Mapping

| JD Requirement | Where in this codebase |
|---|---|
| **OOP** | Sprint 1 (Authenticatable concern), Sprint 2 (BookingService, AvailabilityChecker), Sprint 3 (ReportQuery) |
| **Database / Migration design** | All `db/migrate/*` files, 5 tables with proper FKs, indexes, unique constraints |
| **SQL (big plus)** | `app/services/report_query.rb` — 3 hand-written queries with `EXISTS`, `JOIN`, window function |
| **HTML / CSS** | All `app/views/**/*.erb` + handwritten CSS in `app/assets/stylesheets/application.css` |
| **Git Flow** | `docs/GIT_FLOW.md`; version tags `v0.1` → `v1.0` (see CHANGELOG.md) |
| **Estimate tasks** | This file, `TASKS.md` |
| **Report progress** | Tags + CHANGELOG.md milestones |

---

## Velocity / Cadence

- **Daily standups (self):** 5 min — review yesterday, set today, highlight blockers
- **End of sprint:** merge feature → develop, tag version, run integration smoke
- **End of project:** merge release/v1.0 → master, tag v1.0, deploy
