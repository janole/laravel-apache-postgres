# "base" is the parent image, wired up in docker-bake.hcl.
FROM base

USER root

RUN mkdir -p /usr/share/man/man1 && apt-get update \
#
# Install node
#
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
#
# Clean-up
#
    && rm -rf /var/lib/apt/lists/*

USER ${APACHE_RUN_USER}

