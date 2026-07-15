ARG BASE_IMAGE=libops/omeka-classic:3.2.1-php84@sha256:b668d895e0334c5367991994f0f4e2165fb932a31b89057721c5669d941965aa
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-classic

# nginx:nginx in the base image.
COPY --link --chown=100:101 plugins/ /var/www/omeka-classic/plugins/
COPY --link --chown=100:101 themes/ /var/www/omeka-classic/themes/
