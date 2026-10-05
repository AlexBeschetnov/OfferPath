# 💼 OfferPath — Job Search Tracker

![CI](../../actions/workflows/ci.yml/badge.svg)

A Ruby on Rails 8 app for people who are looking for a job. Keep every application in one place,
move it through a hiring pipeline, see your conversion stats, and get nudged when it's time to follow up.

## Features

- **Accounts.** Sign up and sign in with built-in authentication (`has_secure_password`, database-backed sessions, rate-limited login).
- **Applications.** Company, position, salary range, job posting link, notes, and the next step with its due date.
- **Kanban board.** Move an application to the next stage in one click: *Wishlist → Applied → Interview → Offer / Rejected*.
- **Status history.** Every status change is recorded automatically and shown as a timeline.
- **Dashboard:**
  - pipeline breakdown by status;
  - application-to-interview conversion rate;
  - upcoming steps, with overdue ones highlighted;
  - applied or interviewing applications with no movement for 14+ days, so you know when to send a follow-up.
- **Search and filters** by company, position, and status.
- **CSV export** that opens correctly in Excel (UTF-8 with BOM).

## Technical highlights

| What | Where |
|------|-------|
| Per-user data isolation: every query is scoped to `Current.user.job_applications`, so another user's record returns 404 | `app/controllers/job_applications_controller.rb` |
| Authentication: signed cookie, sessions stored in the database, `rate_limit` on sign-in | `app/controllers/concerns/authentication.rb` |
| String-backed enum with validation, `normalizes`, custom salary range validation | `app/models/job_application.rb` |
| Status history recorded through `before_save` / `after_save` callbacks | `app/models/job_application.rb` |
| Query object for dashboard stats; conversion rate computed with a subquery over the history table | `app/models/job_search_stats.rb` |
| Search that escapes LIKE wildcards (`sanitize_sql_like` + `ESCAPE`) | `JobApplication.search` |
| UI copy, attribute names, and validation messages via I18n | `config/locales/en.yml` |
| Hotwire Turbo with no JS build step (importmap + Propshaft) | `config/importmap.rb` |
| Model and integration tests, including access control between users | `test/` |
| Continuous integration with GitHub Actions | `.github/workflows/ci.yml` |

## Getting started

Requirements: Ruby 4.0 (see `.ruby-version`). On Windows, use [RubyInstaller](https://rubyinstaller.org/downloads/) **with DevKit**.

```bash
bundle install
bin/rails db:prepare     # creates the database and loads demo data
bin/rails server
```

On Windows, prefix the commands with `ruby`, e.g. `ruby bin/rails server`.

Open http://localhost:3000 and sign in with the demo account:

- email: `demo@example.com`
- password: `password123`

## Running tests

```bash
bin/rails test
```

## Tech stack

Ruby on Rails 8 · SQLite · Hotwire Turbo · Importmap · Propshaft · Minitest · GitHub Actions
