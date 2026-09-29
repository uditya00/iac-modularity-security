#!/usr/bin/env bash
# Usage: source scripts/env.sh
# Creates a random DB password once (stored in .env, git-ignored) and exports it.
if [ ! -f .env ]; then
  echo "TFSTATE_DB_PASSWORD=$(openssl rand -hex 16)" > .env
  chmod 600 .env
fi
set -a; . ./.env; set +a
export PG_CONN_STR="postgres://tfstate:${TFSTATE_DB_PASSWORD}@127.0.0.1:5432/tfstate?sslmode=disable"
echo "Environment ready (password is in .env, not in Git)."
