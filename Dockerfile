ARG WILDFLY_RELEASE=latest
ARG DOCKER_BASE=jboss/wildfly
FROM ${DOCKER_BASE}:${WILDFLY_RELEASE}

LABEL maintainer="Harald Pehl <hpehl@redhat.com>"

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=20 CMD curl -f http://localhost:9990/ || exit 1

RUN /opt/jboss/wildfly/bin/add-user.sh -u admin -p admin --silent
RUN for conf in /opt/jboss/wildfly/standalone/configuration/standalone*.xml; do sed -e 's/<http-interface\(.*\)security-realm="ManagementRealm"\(.*\)>/<http-interface\1\2>/' -e 's/<http-interface\(.*\)http-authentication-factory="management-http-authentication"\(.*\)>/<http-interface\1\2>/' -e 's/<http-upgrade\(.*\)sasl-authentication-factory="management-sasl-authentication"\(.*\)\/>/<http-upgrade\1\2\/>/' "${conf}" > "${conf%%.*}-insecure.${conf#*.}"; done
RUN sed -i '/allowed-origins=".*"/! s/<http-interface\(.*\)>/<http-interface\1 allowed-origins="http:\/\/localhost:8888 http:\/\/localhost:9090 http:\/\/hal.github.io https:\/\/hal.github.io">/' /opt/jboss/wildfly/standalone/configuration/standalone*.xml
ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
CMD ["-c", "standalone.xml"]
