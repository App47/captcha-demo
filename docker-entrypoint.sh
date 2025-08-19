#!/usr/bin/env bash
set -euo pipefail

# Ensure we have a database connection before running migrations
# You can add a small wait loop for DB if needed
# Example (Postgres):
# until bundle exec rails db:prepare 2>/dev/null; do
#   echo "DB not ready yet, retrying in 3s..."
#   sleep 3
# done

# Run non-destructive migrations and schema load safely
# bundle exec rails db:prepare

exec "$@"
