ARG WILDFLY_RELEASE=latest
ARG DOCKER_BASE=jboss/wildfly
FROM ${DOCKER_BASE}:${WILDFLY_RELEASE}

LABEL maintainer="Harald Pehl <hpehl@redhat.com>"

RUN /opt/jboss/wildfly/bin/add-user.sh -u admin -p admin --silent
RUN sed -i '/allowed-origins=".*"/! s/<http-interface\(.*\)>/<http-interface\1 allowed-origins="http:\/\/localhost:8888 http:\/\/hal.github.io https:\/\/hal.github.io">/' /opt/jboss/wildfly/standalone/configuration/standalone*.xml
ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
CMD ["-c", "standalone.xml"]
