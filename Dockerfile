ARG BASE_IMAGE=libops/omeka-classic:3.2.1-php84@sha256:e979c85f6ed5f4606b62fb1eb49aac5a70504a27e0bf748a1831eb88f3ba76ed
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-classic

# nginx:nginx in the base image.
COPY --link --chown=100:101 plugins/ /var/www/omeka-classic/plugins/
COPY --link --chown=100:101 themes/ /var/www/omeka-classic/themes/
