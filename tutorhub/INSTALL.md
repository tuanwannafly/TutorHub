# Install
This project is a Rails 7.1 app. You'll need:
- **Ruby 3.2.2** (use rbenv, asdf, or RailsInstaller)
- **PostgreSQL 15+** running locally
- **Node 18+**
- **Bundler 2.x**

## One-liner (Ubuntu/WSL)
```bash
sudo apt update && sudo apt install -y ruby ruby-dev build-essential libpq-dev postgresql nodejs npm git
```

## macOS (Homebrew)
```bash
brew install ruby postgresql node
brew services start postgresql
```

## Setup
```bash
git clone https://github.com/<you>/tutorhub.git
cd tutorhub
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server          # http://localhost:3000
bundle exec rspec         # test suite
bundle exec rubocop       # linter
```

## Demo accounts (after `db:seed`)
| Role | Email | Password |
|------|-------|----------|
| tutor | alice@tutorhub.dev | password123 |
| tutor | bob@tutorhub.dev | password123 |
| tutor | carol@tutorhub.dev | password123 |
| tutor | dave@tutorhub.dev | password123 |
| student | student1@tutorhub.dev | password123 |
| student | student2@tutorhub.dev | password123 |
| student | student3@tutorhub.dev | password123 |

## Using Docker (zero local install)
```bash
docker compose up
# → http://localhost:3000
```

## On Windows
- Recommended: use WSL (Ubuntu 22.04). Install WSL with `wsl --install`, then run everything inside.
- Native Windows is supported (Puma + Postgres works) but tooling is rougher.

## Tests
```bash
bundle exec rspec                             # full suite
bundle exec rspec spec/services               # service objects
bundle exec rspec -t concurrency              # only the concurrency specs (heavier)
```

## Common issues
- **`libyaml missing`** — `apt install libyaml-dev`
- **`cannot load such file — pg`** — `apt install libpq-dev`
- **Postgres connection refused** — `service postgresql start`
- **Bundler version mismatch** — `gem install bundler -v 2.5.6`
