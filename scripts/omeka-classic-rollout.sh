#!/usr/bin/env sh

set -eu

readonly migration_marker='Public site is unavailable until the upgrade completes.'

wait_ready() {
  started="$(date +%s)"
  deadline=$((started + 600))

  until test -f /installed && curl --connect-timeout 2 --max-time 5 -fsS http://127.0.0.1/status | grep -q pool; do
    now="$(date +%s)"
    if test "$now" -ge "$deadline"; then
      echo 'Omeka Classic did not become ready for migration inspection within 10 minutes' >&2
      exit 1
    fi
    sleep 2
  done
}

check_migration() {
  response="$(mktemp)"
  cleanup() {
    rm -f -- "$response"
  }
  trap cleanup EXIT INT TERM

  if curl --connect-timeout 2 --max-time 30 -fsS http://127.0.0.1/ > "$response"; then
    :
  else
    status=$?
    echo "Unable to inspect Omeka Classic migration state (curl status $status)" >&2
    exit "$status"
  fi

  if grep -Fq "$migration_marker" "$response"; then
    echo 'ACTION REQUIRED: Omeka Classic requires its supported browser migration. Public Traefik remains stopped. Run sitectl port-forward 8080:omeka-classic:80, open http://localhost:8080/admin, complete the migration, stop the forward, and rerun sitectl deploy --skip-git --no-pull. If this deploy selected a non-active context, pass the same --context NAME to both sitectl commands.' >&2
    exit 10
  fi
}

case "${1:-}" in
  wait-ready)
    wait_ready
    ;;
  check-migration)
    check_migration
    ;;
  *)
    echo 'usage: sitectl-omeka-classic-rollout {wait-ready|check-migration}' >&2
    exit 2
    ;;
esac
