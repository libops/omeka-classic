# Omeka Classic Docker Template

The Omeka Classic Docker Template gives you a Docker Compose repository for running [Omeka Classic](https://omeka.org/classic/). It includes Traefik, MariaDB, and the LibOps Omeka Classic PHP/nginx image, and is designed to be managed with [`sitectl-omeka-classic`](https://github.com/libops/sitectl-omeka-classic).

Docs:

- [Managed application architecture](https://sitectl.libops.io/apps)
- [Omeka Classic sitectl plugin](https://sitectl.libops.io/plugins/omeka-classic)

## Requirements

- [sitectl](https://sitectl.libops.io/install) installed on the host that will run the site.
- [`sitectl-omeka-classic`](https://github.com/libops/sitectl-omeka-classic) installed for Omeka Classic create, validation, healthcheck, and helper commands.
- Docker with the Compose v2 plugin installed on the same host.

## Quick start

Create a new Omeka Classic site from this template:

```bash
sitectl create omeka-classic/default \
  --template-repo https://github.com/libops/omeka-classic \
  --path ./my-omeka-classic-site \
  --type local \
  --checkout-source template \
  --default-context
```

The site is served through Traefik at `http://localhost`. The first boot creates the database and submits the Omeka Classic installer automatically. The default admin password is generated in `./secrets/OMEKA_CLASSIC_ADMIN_PASSWORD`.

## Local image build

The `omeka-classic` service builds this checkout on top of the LibOps Omeka Classic base image. The Dockerfile downloads the pinned Omeka Classic release, installs Composer dependencies, then copies local plugins and themes so Docker can reuse dependency layers when only site customizations change. Local builds use the platform selected by the Docker CLI and do not push images.

## Basic Operations

Run these from the generated checkout, or add `--context <name>` when operating from elsewhere.

Start or update the stack with [`sitectl compose`](https://sitectl.libops.io/commands/compose):

```bash
sitectl compose up --remove-orphans -d
```

Check the site and context configuration with [`sitectl healthcheck`](https://sitectl.libops.io/commands/healthcheck) and [`sitectl validate`](https://sitectl.libops.io/commands/validate):

```bash
sitectl healthcheck
sitectl validate
```

Update image tags or pin a full image reference with [`sitectl image`](https://sitectl.libops.io/commands/image):

```bash
sitectl image set --tag omeka-classic=nginx-1.30.3-php84
sitectl image set --image omeka-classic=libops/omeka-classic:nginx-1.30.3-php84@sha256:...
```

Enable local development bind mounts with [`sitectl set`](https://sitectl.libops.io/commands/set), then apply the component change with [`sitectl converge`](https://sitectl.libops.io/commands/converge):

```bash
sitectl set dev-mode enabled
sitectl converge
```

Publish a domain, switch HTTP/TLS mode, configure Let's Encrypt, trust upstream proxies, or tune upload limits with the `ingress` component:

```bash
sitectl set ingress enabled --mode https-default --domain omeka-classic.localhost
sitectl set ingress enabled --mode https-letsencrypt --domain omeka-classic.example.org --acme-email ops@example.org
sitectl set ingress enabled --trusted-ip 203.0.113.10/32 --max-upload-size 2G --upload-timeout 10m
sitectl converge
```

The ingress component writes `INGRESS_HOSTNAMES` as comma-separated hostnames and `INGRESS_SCHEME` as `http` or `https` into the app container. Runtime config is rendered from those values during container startup, so generated sites should not carry separate app URL env vars for the same public route.

See the [Omeka Classic sitectl plugin docs](https://sitectl.libops.io/plugins/omeka-classic) for lifecycle operations, API helpers, resource shortcuts, and plugin maintenance.

## Makefile

The Makefile is intentionally small. It only keeps template-specific targets that are not core sitectl operations:

```bash
sitectl deploy
make test
make lint
```

Use `sitectl compose ...` and `sitectl set ...` directly for normal stack operations.

## Template notes

- `traefik` is the only published ingress.
- `omeka-classic` is built from this repository and based on the LibOps Omeka Classic PHP/nginx image.
- `mariadb` stores application data.
- `omeka-classic-files` persists uploaded files.
- Secrets are generated into `./secrets/`.

PHP `mail()` is routed through `msmtp`. By default, Omeka Classic relays through the Docker host so production delivery can use the host MTA and LibOps relay path.

## License

The Docker Compose template and LibOps-specific setup in this repository are licensed under the MIT License. Omeka Classic is licensed separately under the GNU General Public License v3; see `LICENSE.omeka-classic`.
