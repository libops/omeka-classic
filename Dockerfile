ARG BASE_IMAGE=libops/omeka-classic:nginx-1.30.3-php84@sha256:9cf8f297ebb14b5ed11b45730f0072343199f5cdc5c14530d36cebe063c255c6
FROM ${BASE_IMAGE}

ARG TARGETARCH

ARG \
    # renovate: datasource=repology depName=alpine_3_24/unzip
    UNZIP_VERSION=6.0-r16 \
    # renovate: datasource=github-releases depName=omeka-classic packageName=omeka/Omeka
    SOFTWARE_VERSION=3.2
ARG FILE=omeka-${SOFTWARE_VERSION}.zip
ARG URL=https://github.com/omeka/Omeka/releases/download/v${SOFTWARE_VERSION}/${FILE}
ARG SHA256="740626c1258092dde0d905ff4ba09bec5607e2b79872d894c5e72507346ce169"

ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /var/www/omeka-classic

RUN --mount=type=cache,id=custom-omeka-classic-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        unzip=="${UNZIP_VERSION}" \
    && \
    cleanup.sh

RUN --mount=type=cache,id=custom-omeka-classic-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${URL}" \
        --sha256 "${SHA256}" \
        --strip \
        --dest "/var/www/omeka-classic" \
    && \
    mkdir -p /var/www/omeka-classic/files && \
    cleanup.sh

COPY --link composer.json composer.lock /var/www/omeka-classic/

RUN --mount=type=cache,id=custom-omeka-classic-composer-${TARGETARCH},sharing=locked,target=/root/.composer/cache \
    composer install -d /var/www/omeka-classic --no-interaction --no-progress --prefer-dist --no-dev --optimize-autoloader && \
    cleanup.sh

COPY --link plugins/ /var/www/omeka-classic/plugins/
COPY --link themes/ /var/www/omeka-classic/themes/

ENV \
    DB_HOST=mariadb \
    DB_PORT=3306 \
    DB_NAME=omeka_classic \
    DB_USER=omeka_classic \
    DB_PASSWORD=changeme \
    OMEKA_CLASSIC_ADMIN_USERNAME=admin \
    OMEKA_CLASSIC_ADMIN_EMAIL=admin@example.com \
    OMEKA_CLASSIC_ADMIN_PASSWORD=changeme \
    OMEKA_CLASSIC_SITE_TITLE="Omeka Classic" \
    OMEKA_CLASSIC_TABLE_PREFIX=omeka_ \
    OMEKA_CLASSIC_ENABLE_HTTPS=false \
    LIBOPS_SMTP_HOST=host.docker.internal \
    LIBOPS_SMTP_PORT=25 \
    SMTP_FROM=

RUN chown -R nginx:nginx /var/www/omeka-classic && \
    cleanup.sh
