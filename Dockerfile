ARG BASE_IMAGE=libops/omeka-classic:3.2.1-php84@sha256:51756d75db869e223098e3bf917cdb405334f84b267794b4b0ac7bfdba3c28ed
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-classic

# nginx:nginx in the base image.
COPY --link --chown=100:101 plugins/ /var/www/omeka-classic/plugins/
COPY --link --chown=100:101 themes/ /var/www/omeka-classic/themes/
