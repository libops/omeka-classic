ARG BASE_IMAGE=libops/omeka-classic:3.2.1-php84@sha256:43f0f3d6cfbd670743e9eea062215f406e32cebd1f29825b093c9e4b6e500307
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-classic

# nginx:nginx in the base image.
COPY --link --chown=100:101 plugins/ /var/www/omeka-classic/plugins/
COPY --link --chown=100:101 themes/ /var/www/omeka-classic/themes/
