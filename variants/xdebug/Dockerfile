# "base" is the parent image, wired up in docker-bake.hcl.
FROM base

USER root

#
# Install xdebug
#
# Normally the newest release from pecl.php.net. pecl.php.net regularly answers with HTTP 500
# for minutes at a time, so retry once and then build XDEBUG_FALLBACK_VERSION from the GitHub
# source instead. Bump the fallback now and then; it is only used while pecl is down.
ARG XDEBUG_FALLBACK_VERSION=3.5.3
RUN ( pecl install xdebug \
        || (sleep 20 && pecl install xdebug) \
        || ( echo "pecl.php.net failed, building xdebug ${XDEBUG_FALLBACK_VERSION} from GitHub" \
            && mkdir -p /tmp/xdebug \
            && curl -fsSL --retry 3 "https://github.com/xdebug/xdebug/archive/refs/tags/${XDEBUG_FALLBACK_VERSION}.tar.gz" \
                | tar -xz --strip-components=1 -C /tmp/xdebug \
            && cd /tmp/xdebug \
            && phpize \
            && ./configure --enable-xdebug \
            && make -j"$(nproc)" \
            && make install ) ) \
    && docker-php-ext-enable xdebug \
    && php -m | grep -qx xdebug \
    && rm -rf /tmp/pear /tmp/xdebug

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
