ARG FROM
FROM $FROM

USER root

RUN mkdir -p /usr/share/man/man1 && apt-get update \
#
# Install some imaging tools
#
    && apt-get install -y --no-install-recommends imagemagick poppler-utils exiftool libtiff-tools \
#
# Install unoconv ...
#
    && apt-get install -y --no-install-recommends unoconv \
#
# Install PDF tools ...
#
    && apt-get install -y --no-install-recommends qpdf pdftk-java \
#
# For unoconv, chown /var/www to www-data:www-data
#
    && chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} $(eval echo "~$APACHE_RUN_USER") \
#
# Clean-up
#
    && rm -rf /var/lib/apt/lists/*

USER ${APACHE_RUN_USER}
