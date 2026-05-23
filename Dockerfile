FROM islandora/nginx:6.2.3@sha256:1e85a1f0a222289a3079d5740ce8156d36c325c1f8477fb96806fa157cfb666b

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

EXPOSE 80

WORKDIR /var/www/omeka-classic

ARG \
    # renovate: datasource=github-releases depName=omeka-classic packageName=omeka/Omeka
    OMEKA_CLASSIC_VERSION=3.2 \
    # renovate: datasource=repology depName=alpine_3_22/php83
    PHP_VERSION=8.3.29-r0

RUN apk add --no-cache \
    curl \
    imagemagick \
    msmtp \
    php83-exif=="${PHP_VERSION}" \
    php83-gd=="${PHP_VERSION}" \
    php83-mysqli=="${PHP_VERSION}" \
    unzip \
    && curl -fsSL "https://github.com/omeka/Omeka/releases/download/v${OMEKA_CLASSIC_VERSION}/omeka-${OMEKA_CLASSIC_VERSION}.zip" -o /tmp/omeka-classic.zip \
    && unzip /tmp/omeka-classic.zip -d /tmp \
    && cp -a /tmp/omeka-${OMEKA_CLASSIC_VERSION}/. /var/www/omeka-classic/ \
    && rm -rf /tmp/omeka-classic.zip /tmp/omeka-${OMEKA_CLASSIC_VERSION} \
    && mkdir -p /var/www/omeka-classic/files \
    && chown -R nginx:nginx /var/www/omeka-classic \
    && cleanup.sh

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
    SMTP_FROM= \
    PHP_MAX_EXECUTION_TIME=300 \
    PHP_MAX_INPUT_TIME=300 \
    PHP_DEFAULT_SOCKET_TIMEOUT=300 \
    PHP_REQUEST_TERMINATE_TIMEOUT=300 \
    PHP_MEMORY_LIMIT=256M \
    NGINX_FASTCGI_READ_TIMEOUT=300s \
    NGINX_FASTCGI_SEND_TIMEOUT=300s \
    NGINX_FASTCGI_CONNECT_TIMEOUT=300s

COPY --link rootfs /
