ARG FROM
FROM $FROM

USER root

RUN true \
#
# Update package list
#
    && apt-get update \
#
# Install modsecurity2
#
    && apt-get install -y --no-install-recommends libapache2-mod-security2 unzip \
    && a2enmod security2 \
    && cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf \
#
# Clean-up
#
    && rm -rf /var/lib/apt/lists/*

RUN true \
#
# Download and unpack OWASP ModSecurity Core Rule Set (CRS)
#
    && cd /tmp \
    && curl -L https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.4.zip --output /tmp/v3.3.4.zip \
    && unzip /tmp/v3.3.4.zip \
#
# Copy OWASP ModSecurity Core Rule Set (CRS)
#
    && cp /tmp/coreruleset-3.3.4/crs-setup.conf.example /etc/modsecurity/crs-setup.conf \
    && mv /tmp/coreruleset-3.3.4/rules/ /etc/modsecurity/ \
#
# Remove new config incompatible with Ubuntu distro modsecurity2
#
    && rm /etc/modsecurity/rules/REQUEST-922-MULTIPART-ATTACK.conf \
#
# Use env variable to switch between On & DetectionOnly
#
    && sed -ri -e 's!SecRuleEngine .*!SecRuleEngine ${SEC_RULE_ENGINE}!g' /etc/modsecurity/modsecurity.conf \
#
# Clean-up
#
    && rm -rf /tmp/*

# Enable/use OWASP ModSecurity Core Rule Set (CRS)
COPY ./security2.conf /etc/apache2/mods-enabled/

# Set ModSecurity to "On" by default
ENV SEC_RULE_ENGINE=On

#
USER ${APACHE_RUN_USER}
