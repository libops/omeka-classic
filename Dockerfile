ARG BASE_IMAGE=libops/omeka-classic:3.2.1-php84@sha256:6d71c19f3bc6b8c06f213384ba4ee8cf040f1d5b00f6a8f71ff47e4565d074c2
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-classic

# nginx:nginx in the base image.
COPY --link --chown=100:101 plugins/ /var/www/omeka-classic/plugins/
COPY --link --chown=100:101 themes/ /var/www/omeka-classic/themes/
