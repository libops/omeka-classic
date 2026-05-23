# Omeka Classic Docker Template

LibOps-owned Docker Compose template for Omeka Classic.

## Quick Start

```bash
make up
```

The site is served through Traefik at `http://localhost`. The Omeka Classic first-boot setup creates the database and submits the installer automatically.

`make up` runs `scripts/init-if-needed.sh`, which inspects the rendered Docker Compose config and only runs the `init` service when required secrets or named volumes are missing.

Default admin values:

- Username: `admin`
- Password: `./secrets/OMEKA_CLASSIC_ADMIN_PASSWORD`
- Email: `admin@example.com`

## Layout

- `docker-compose.yaml` defines the production-style stack.
- `init` generates file-backed secrets before the stack starts.
- `traefik` is the only HTTP ingress.
- `omeka-classic` is built from this repository and based on the Islandora Omeka Classic PHP/nginx image.
- `mariadb` uses the Islandora MariaDB image.
- `omeka-classic-files` persists uploaded files.

`docker-compose.yaml` is the production-shaped default. Local development changes should be copied from `docker-compose.override-example.yaml` to `docker-compose.override.yaml`; the example only exposes MariaDB for debugging.

## SMTP

PHP `mail()` is routed through `msmtp`. By default, Omeka Classic relays through `${LIBOPS_SMTP_HOST:-host.docker.internal}:${LIBOPS_SMTP_PORT:-25}` so production delivery is handled by the host MTA and LibOps relay path. The override example adds Mailpit and points the app at `mailpit:1025` for local testing.

## Rollouts

`make rollout` runs `scripts/rollout.sh`, which checks out the requested git ref when provided, pulls/builds images, runs the init gate, and converges the Compose stack. LibOps API registrations should use `./scripts/rollout.sh` for this template's `RolloutCmd`.

## Updates

Renovate tracks:

- Omeka Classic GitHub releases through the Dockerfile build argument.
- Docker images in Compose and Dockerfile.
- Shared LibOps Renovate defaults through `github>libops/renovate-config`.
