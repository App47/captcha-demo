# syntax=docker/dockerfile:1.7
FROM ruby:3.2 AS base

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test" \
    RAILS_ENV=production \
    RACK_ENV=production

WORKDIR /app

# Install system deps (choose sqlite or postgres client as needed)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential curl ca-certificates libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# Cache gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# App code
COPY . .

# Precompile bootsnap (if enabled) and assets if any (this is a server-rendered app)
# RUN bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bash", "-lc", "bundle exec puma -C config/puma.rb"]