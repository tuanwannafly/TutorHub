# Changelog

All notable changes to TutorHub.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - Sprint 4 complete
### Added
- GitHub Actions CI running RSpec + RuboCop
- Docker Compose dev stack (Postgres + Rails)
- Production Docker image

### Changed
- README polished
- Seed data expanded

## [0.4.0] - Sprint 3 complete
### Added
- `ReportQuery` class with three hand-written SQL reports (NOT EXISTS, JOIN+GROUP BY, window function)
- Admin-style reports dashboard (`/reports/tutors`, `/reports/revenue`, `/reports/top_tutors`)
- `Review` model + review flow (rating 1-5, one per booking, only after completion)

## [0.3.0] - Sprint 2 complete
### Added
- `Availability` model with weekly-window constraints and overlap detection
- `Booking` model with hand-rolled state machine (`pending/confirmed/completed/cancelled`)
- **`BookingService` PORO** — centerpiece of the project — DB unique index + optimistic locking prevent double-booking
- Concurrency spec: 5 parallel threads, only 1 succeeds
- BookingsController with role-based authorization (tutor confirm/complete, either can cancel)
- Bookings views (status badge partial, detail page)

## [0.2.0] - Sprint 1 complete
### Added
- `User` model with `has_secure_password`, role enum, email normalisation
- `TutorProfile` model with hourly rate and bio
- `Authenticatable` concern — `current_user`, `require_login`, `require_role`
- `SessionsController` / `RegistrationsController` — no Devise
- Hand-written CSS for the entire site (no framework)

## [0.1.0] - Sprint 0 complete
### Added
- Rails 7.1 + Postgres scaffold
- RSpec + FactoryBot + Faker + Shoulda Matchers + DatabaseCleaner
- RuboCop + `rails` config
- ERD (`docs/ARCHITECTURE.md`)
- `TASKS.md` with hour estimates
