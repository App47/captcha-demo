# syntax=docker/dockerfile:1

# -------- Builder stage --------
FROM ruby:3.2.3-slim AS builder

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_PATH=/usr/local/bundle \
    APP_HOME=/app

WORKDIR $APP_HOME

# Install OS deps for building gems and JS
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
    libpq-dev \
    pkg-config \
    nodejs \
    npm \
  && rm -rf /var/lib/apt/lists/*

# Install bundler at project-pinned version if needed
# ENV BUNDLER_VERSION=2.7.1
# RUN gem install bundler -v "$BUNDLER_VERSION"

# Preinstall gems based on Gemfile + lock
COPY Gemfile Gemfile.lock ./
RUN bundle config set deployment 'true' \
 && bundle config set without "$BUNDLE_WITHOUT" \
 && bundle install --jobs=4 --retry=3

# Install JS deps
# COPY package.json package-lock.json ./
# RUN npm ci --no-audit --no-fund

# Copy the rest of the app
COPY . .

# Precompile assets (when using sprockets/rollup/trix) — SECRET_KEY_BASE needed by Rails for some tasks
# Use a dummy during build; real one is injected at runtime
#RUN bundle exec rake assets:precompile

# -------- Runtime stage --------
FROM ruby:3.2.3-slim AS app

ENV RAILS_ENV=production \
    RACK_ENV=production \
    APP_HOME=/app \
    BUNDLE_PATH=/usr/local/bundle \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    PORT=3000

WORKDIR $APP_HOME

# Install only runtime packages
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libpq5 \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -m -u 10001 appuser

# Copy app from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Entrypoint handles migrations then boots Puma
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

EXPOSE 3000
USER appuser

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]