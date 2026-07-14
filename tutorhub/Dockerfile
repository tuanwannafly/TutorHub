# Dockerfile — production image, used by Render / Fly.io / Heroku-ish.
FROM ruby:3.2.2-slim

ENV LANG=C.UTF-8 \
    BUNDLE_PATH=/usr/local/bundle \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

RUN apt-get update -qq && \
    apt-get install -yqq --no-install-recommends \
      build-essential libpq-dev nodejs npm curl libvips && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4

COPY package.json yarn.lock ./
RUN npm install --silent

COPY . .

RUN bundle exec bootsnap precompile --app-dir=. || true && \
    bundle exec rake assets:precompile || true

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
