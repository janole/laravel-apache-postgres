# "base" is the parent image, wired up in docker-bake.hcl.
FROM base

USER root

#
# Install xdebug
#
# pecl.php.net occasionally answers with HTTP 500, so retry the download twice.
RUN ( pecl install xdebug || (sleep 20 && pecl install xdebug) || (sleep 60 && pecl install xdebug) ) \
    && docker-php-ext-enable xdebug \
    && rm -rf /tmp/pear

# The xdebug.ini contains mostly ENV vars for easy overriding
COPY ./xdebug.ini $PHP_INI_DIR/conf.d/zzzz-xdebug.ini

# Default settings for xdebug
ENV XDEBUG_REMOTE_ENABLE=1
# Try to connect to host (this will work with Docker for Mac/Windows only.)
# See https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds
# See https://docs.docker.com/docker-for-windows/networking/#use-cases-and-workarounds
# See https://github.com/qoomon/docker-host for Linux
ENV XDEBUG_REMOTE_HOST="host.docker.internal"
ENV XDEBUG_REMOTE_PORT=9000
# XDEBUG v3
ENV XDEBUG_MODE=debug
ENV XDEBUG_CLIENT_HOST="host.docker.internal"
ENV XDEBUG_CLIENT_PORT=9003
ENV XDEBUG_START_WITH_REQUEST="yes"

USER ${APACHE_RUN_USER}
