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

The `omeka-classic` service builds this checkout on top of the app-versioned LibOps Omeka Classic image. Omeka Classic core and its application dependencies are already present in that image; this template image only adds the plugins and themes owned by the downstream site. Local builds use the platform selected by the Docker CLI and do not push images.

Docker Compose derives the project name from the checkout directory, so independent forks do not share containers, networks, or named volumes by default. Set `COMPOSE_PROJECT_NAME` explicitly when a stable name is required.

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

Update the application base tag or pin that base by digest with [`sitectl image`](https://sitectl.libops.io/commands/image):

```bash
sitectl image set --tag omeka-classic=3.2.1-php84
sitectl image set --build-arg omeka-classic.BASE_IMAGE=libops/omeka-classic:3.2.1-php84@sha256:...
```

The image tag starts with the Omeka Classic release and ends with the PHP flavor. Updating that base image and rebuilding the derived site image upgrades application core without copying core into the downstream repository. Back up the database and `omeka-classic-files` volume before an application upgrade. After the new container starts, sign in at `/admin` and complete any database migration prompt; the upgrade is not complete until that succeeds.

Publish a domain, switch HTTP/TLS mode, configure Let's Encrypt, trust upstream proxies, or tune upload limits with the `ingress` component:

```bash
sitectl set ingress enabled --mode https-custom --domain omeka-classic.localhost
sitectl set ingress enabled --mode https-letsencrypt --domain omeka-classic.example.org --acme-email ops@example.org
sitectl set ingress enabled --trusted-ip 203.0.113.10/32 --max-upload-size 2G --upload-timeout 10m
```

`sitectl set` applies the requested component change immediately. Use `sitectl converge` when you want an interactive review of the complete component state.

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
- `omeka-classic` is a small downstream customization image based on the app-versioned LibOps Omeka Classic image.
- `mariadb` stores application data.
- `omeka-classic-files` persists uploaded files.
- Secrets are generated into `./secrets/`.

Application core and its dependencies belong to the base image. Downstream code belongs under `plugins/` and `themes/`; do not copy or bind-mount the complete Omeka Classic application tree over the image.

Rebuild and redeploy the derived site image after changing a checked-in plugin or theme. These directories are intentionally not bind-mounted over the base image because doing so would hide plugins and themes shipped by Omeka Classic.

Only MariaDB and the one-shot `database-init` service receive `DB_ROOT_PASSWORD`. The initializer idempotently creates the database and scoped user before Omeka Classic starts; the long-running app receives only `OMEKA_CLASSIC_DB_PASSWORD` as `DB_PASSWORD`.

PHP `mail()` is routed through `msmtp`. By default, Omeka Classic relays through the Docker host so production delivery can use the host MTA and LibOps relay path.

## License

The Docker Compose template and LibOps-specific setup in this repository are licensed under the MIT License. Omeka Classic is licensed separately under the GNU General Public License v3; see `LICENSE.omeka-classic`.
