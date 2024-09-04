ARG FROM
FROM $FROM

USER root

RUN mkdir -p /usr/share/man/man1 && apt-get update \
#
# Install node
#
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
#
# Clean-up
#
    && rm -rf /var/lib/apt/lists/*

USER ${APACHE_RUN_USER}

