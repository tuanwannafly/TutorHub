# Setup Guide

## Option A — One-line install (WSL Ubuntu recommended)

```bash
# Inside WSL Ubuntu 22.04:
sudo apt-get update && sudo apt-get install -y \
  build-essential libssl-dev libreadline-dev zlib1g-dev libpq-dev \
  postgresql postgresql-contrib nodejs npm git curl
```

Then install Ruby with [rbenv](https://github.com/rbenv/rbenv) (recommended) or `asdf`.

## Option B — Docker (zero local setup)

```bash
docker compose up    # db + web together
```

## Local Postgres quickstart

```bash
sudo service postgresql start
sudo -u postgres createuser -s tutorhub
sudo -u postgres createdb tutorhub_dev -O tutorhub
sudo -u postgres createdb tutorhub_test -O tutorhub
```

If you get a peer-auth error, edit `config/database.yml` to use:

```yaml
host: localhost
username: postgres
password: <your pw>     # set via sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'pw';"
```

## Ruby + Bundler

```bash
git clone https://github.com/<you>/tutorhub.git
cd tutorhub
rbenv install 3.2.2        # or use whatever the Gemfile says, see `.ruby-version`
bundle install
```

## Boot the app

```bash
bin/rails db:create db:migrate db:seed
bin/rails server
# open http://localhost:3000
```

## Run the tests

```bash
bundle exec rspec          # full suite
bundle exec rspec spec/models
bundle exec rspec spec/services/booking_service_spec.rb
```

## Demo credentials (after seeding)

| Role | Email | Password |
|---|---|---|
| Tutor | alice@tutorhub.dev | password123 |
| Tutor | bob@tutorhub.dev | password123 |
| Tutor | carol@tutorhub.dev | password123 |
| Tutor | dave@tutorhub.dev | password123 |
| Student | student1@tutorhub.dev | password123 |
| Student | student2@tutorhub.dev | password123 |
| Student | student3@tutorhub.dev | password123 |

## Common issues

- **libyaml missing** — `sudo apt install libyaml-dev`
- **Node 18+ missing** — `sudo apt install -y nodejs` or use `nvm install 18`
- **Postgres port already in use** — `sudo service postgresql restart`
- **Bundler complains about Ruby version** — check `.ruby-version`, run `rbenv install`
