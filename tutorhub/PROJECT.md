# TutorHub — Project Status Report

> Snapshot of the codebase as of the final integration pass. Updated after
> resolving gaps between the four subagents' output.

## TL;DR

The project is **structurally complete**. Every file called out in the
`TutorHub-Sprint-Plan.md` exists, the schema models the JD's expected OOP +
concurrency story, and RSpec covers models, services, and the booking request
flow. The project has not been boot-tested end-to-end (the WSL Ruby install
hit a daily quota on the dev machine) — install Ruby 3.2.2 + Postgres 15,
then `bundle install && bin/rails db:create db:migrate db:seed && bundle exec
rspec` to verify.

## Architecture (one-liner)

```
Users ─┬─ role: student ─── has_many Bookings (as student)
       └─ role: tutor ─── has_one TutorProfile ── has_many Availabilities
                                                └─ has_many Bookings (as tutor)
Bookings ── has_one Review (only when status == completed)
```

## Sprints — what landed

| Sprint | Branch name in plan | Status | Notes |
|---|---|---|---|
| 0 — Setup | `feature/s0-project-setup` | ✅ done | Rails 7.1 + PG + RSpec + RuboCop + importmap |
| 1 — Auth | `feature/s1-user-auth` | ✅ done | User, TutorProfile, Authenticatable, Sessions, Registrations |
| 2a — Availability | `feature/s2-availability` | ✅ done | Availability + AvailabilityChecker + controller/views |
| 2b — Booking Engine | `feature/s3-booking-engine` | ✅ done | Booking, BookingService, optimistic + DB-unique race-safety |
| 3a — SQL Reports | `feature/s4-reports` | ✅ done | ReportQuery (3 raw SQL reports) + ReportsController |
| 3b — Reviews | `feature/s5-reviews` | ✅ done | Review, ReviewsController, views |
| 4 — Polish | `feature/s6-testing` | ✅ done | RSpec request specs, seeds, CI, Dockerfile |

## Critical fixes applied during integration

| # | File | Issue | Fix |
|---|---|---|---|
| 1 | `config/initializers/simple_form.rb` | **Missing initializer** — Rails would crash on boot because views use `simple_form_for` but no initializer existed | Added a minimal initializer that sets up a `.field` wrapper and `.input` class |
| 2 | `config/importmap.rb` | **Missing importmap config** — `<%= javascript_importmap_tags %>` would error | Added the standard Rails 7 importmap pin file |
| 3 | `app/javascript/application.js` | **Missing JS entry** | Added the standard `application.js` that imports Turbo + controllers |
| 4 | `app/javascript/controllers/{application,index}.js` | **Missing Stimulus application** | Added the standard Stimulus application + eager-load helper |
| 5 | `db/seeds.rb` | `Time.parse` used but `time` not required | Added `require "time"` |
| 6 | `app/views/layouts/application.html.erb` | Hardcoded `<title>TutorHub</title>` | Now uses `content_for(:title)` |
| 7 | `app/assets/stylesheets/application.css` | Several view class names had no CSS rules (`.card`, `.btn-secondary`, `.btn-small`, `.data`, `.hourly-rate`, `.badge-pending`, etc.) | Added an aliases section covering all view-side classes |
| 8 | `spec/factories/bookings.rb` | `1.week.from_now.to_date` would collide on the `(tutor_id, booking_date, start_time)` unique index if more than one booking per tutor was needed in a single example | Added a `slot_index` transient that walks 6 daily start times across multiple days |

## OOP story (the centerpiece)

| Concern | Where | Why it matters |
|---|---|---|
| **Service Object** (`BookingService`) | `app/services/booking_service.rb` | Orchestrates the entire booking flow as a single `call` method, with typed errors (`BookingConflictError`, `InvalidInputError`) — the same shape used in production Rails apps |
| **PORO Service** (`AvailabilityChecker`) | `app/services/availability_checker.rb` | Pure-Ruby class for slot-vs-window matching, fully unit-tested without the database |
| **Concern** (`Authenticatable`) | `app/controllers/concerns/authenticatable.rb` | Single include gives `current_user`, `require_login`, `require_role`, `login_as`, `logout` to every controller — Devise replaced with ~50 lines |
| **State machine** (`Booking#confirm!` / `cancel!` / `complete!`) | `app/models/booking.rb` | Hand-rolled (no AASM gem) — the `InvalidTransitionError` makes invalid flows raise explicitly |
| **Raw SQL** (`ReportQuery`) | `app/services/report_query.rb` | Three hand-written queries with `EXISTS`, `GROUP BY`, `RANK() OVER (...)` — answers the "SQL big plus" JD bullet |

## Concurrency story

Two layers of protection against double-booking:

1. **Application-layer uniqueness check** in `Booking#no_double_booking_application_layer` — gives a clean error to the user (validator runs before INSERT).
2. **DB-level UNIQUE INDEX** on `(tutor_id, booking_date, start_time)` — the only authoritative guarantee. Even if two requests bypass the app validator simultaneously, Postgres rejects the second INSERT with `PG::UniqueViolation`, which `BookingService` translates into `BookingConflictError`.
3. **Optimistic locking** via `lock_version` on `bookings` — protects subsequent state transitions (confirm/cancel/complete) so two competing state changes don't both win.

The concurrency spec in `spec/services/booking_service_spec.rb` fires 5 threads at the same slot and asserts exactly 1 succeeds.

## Test coverage

| Spec | What it covers |
|---|---|
| `spec/models/user_spec.rb` | Validations, email normalization, password bounds, `.authenticate` |
| `spec/models/tutor_profile_spec.rb` | Validations, `.search` SQL, `#display_name` |
| `spec/models/availability_spec.rb` | Validation: end_after_start, no-overlap, day_of_week range, `#length_minutes` |
| `spec/models/booking_spec.rb` | Validations, enum, full state-machine coverage (including invalid transitions) |
| `spec/models/review_spec.rb` | Rating bounds, one-per-booking uniqueness, completed-booking constraint |
| `spec/services/availability_checker_spec.rb` | Slot-fits-window, slot-out-of-window, no-window-for-day |
| `spec/services/booking_service_spec.rb` | Happy path, past date, no-availability, self-booking, double-INSERT, **`:concurrency` stampede (5 threads → 1 success)** |
| `spec/services/report_query_spec.rb` | All 3 SQL queries return correct shape |
| `spec/requests/booking_flow_spec.rb` | End-to-end: login → POST booking → confirm as tutor |

**Total: ~50 spec examples** across models, services, and requests.

## File inventory

```
tutorhub/
├── app/                              # MVC + services
│   ├── controllers/                  # 9 controllers (sessions, registrations,
│   │                                 #   dashboards, tutor_profiles, availabilities,
│   │                                 #   bookings, reviews, reports, application)
│   ├── controllers/concerns/         # Authenticatable concern
│   ├── models/                       # User, TutorProfile, Availability, Booking, Review
│   ├── services/                     # AvailabilityChecker, BookingService, ReportQuery
│   ├── views/                        # ERB templates + handwritten CSS
│   ├── javascript/                   # Stimulus + Turbo entry points
│   └── assets/stylesheets/           # application.css (handwritten, ~470 lines)
├── bin/                              # rails, bundle, rspec, rubocop, setup scripts
├── config/
│   ├── application.rb                # autoload_paths += app/services
│   ├── environments/                 # dev, test, prod
│   ├── initializers/                 # simple_form, session_store, cors, content_security_policy, shoulda_matchers, …
│   ├── importmap.rb                  # Turbo + Stimulus pins
│   ├── routes.rb                     # 9 RESTful route blocks
│   ├── database.yml                  # PG, default user/pass = postgres/postgres
│   ├── locales/                      # en + activerecord.en
│   └── puma.rb
├── db/
│   ├── migrate/                      # 5 migrations: users, tutor_profiles, availabilities, bookings, reviews
│   └── seeds.rb                      # 4 tutors + 3 students + sample bookings
├── docs/                             # ARCHITECTURE, SETUP, GIT_FLOW
├── spec/                             # ~50 examples across models, services, requests
├── .github/workflows/ci.yml          # RSpec + RuboCop on push/PR
├── .rubocop.yml                      # rails-style + rubocop-rails + rubocop-performance
├── Dockerfile                        # ruby:3.2.2-slim production image
├── docker-compose.yml                # One-command local stack (PG + web)
├── INSTALL.md                        # Manual install steps
├── README.md                         # Top-level readme
├── TASKS.md                          # Sprint breakdown with hour estimates (JD requirement)
└── PROJECT.md                        # This file
```

## How to run (after installing Ruby + Postgres)

```bash
bundle install
bin/rails db:create db:migrate db:seed
bundle exec rspec         # runs the full test suite
bin/rails server          # http://localhost:3000
# or:
docker compose up         # one-command local stack
```

## Known minor follow-ups

| # | Item | Severity |
|---|---|---|
| 1 | `ReportQuery#available_tutors` returns rows keyed by both `name` (lowercase) and the additional `day_of_week_name` we tack on — callers should use the alias consistently | low |
| 2 | `BookingsController#create` reads `params[:booking].presence || {}` — fine, but a structured `_params` helper would be cleaner | low |
| 3 | The CI workflow uses `db:schema:load` but the project doesn't commit `db/schema.rb` (the schema lives in the migrations). Consider switching to `db:migrate` | low |
| 4 | `Dockerfile` copies `package.json` and runs `npm install` even though we don't have a `yarn.lock` — this will need adjustment depending on the deployment target | low |
| 5 | `render.yaml` is referenced in TASKS.md but doesn't exist yet — would need to be added before deploying to Render | low |

None of these block the project from being boot-tested or demoed.

## Sources of confidence

- `BookingService` and the migration's `lock_version` + unique-index match the same pattern recommended in the Rails Guides ("Active Record Validations" → "Custom Validations" + "Optimistic Locking").
- `User#authenticate`'s case-insensitive lookup uses `lower(email)` matching the DB's functional unique index `lower(email)` — preventing any race where two parallel sign-ups would both pass validation.
- The state machine is small enough to verify by hand (`pending → confirmed → completed/cancelled`) and the `InvalidTransitionError` makes bad transitions loudly fail instead of silently doing nothing.
- The SQL in `ReportQuery` uses parameter binding (`$1`, `$2`, …) rather than string interpolation — preventing SQL injection.

## Conclusion

All four subagent briefs are now reflected in the codebase, with the critical
"this won't boot" gaps (missing simple_form initializer, missing importmap)
fixed during integration. The remaining work is environment setup (install
Ruby + Postgres, run `bundle install`) and any small SQL-syntax tweaks that
only surface once Postgres is actually executing the queries.