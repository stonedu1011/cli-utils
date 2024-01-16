## Build Container ##
FROM maven:3-jdk-11 AS builder

ARG CONFORMANCE_SUITE_VERSION
WORKDIR /src/


RUN mkdir -p -m 0600 ~/.ssh && \
    echo "StrictHostKeyChecking no " > /root/.ssh/config && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=ssh \
    git clone https://gitlab.com/openid/conformance-suite.git .; \
    git checkout tags/release-v$CONFORMANCE_SUITE_VERSION; \
    mvn -B dependency:go-offline
    
RUN mvn -B clean package -Dmaven.test.skip=true
    

## Distribution Container ##

# This dockerfile is used when running development builds of the server
#
# It is necessary to make selenium work when the server is running on
# within docker on localhost - selenium runs on the jvm container, so
# localhost points at the spring server, whereas selenium needs to talk
# to the ingress httpd.
#
# We install redir, and then the --fintechlabs.startredir=true option
# to java is used to launch it
FROM openjdk:11-jdk-slim
WORKDIR /service/

COPY start.sh /service/
RUN \
  apt-get update && apt-get install redir; \
  chmod +x /service/start.sh;
COPY --from=builder /src/target/fapi-test-suite.jar /service/

ENTRYPOINT ["/service/start.sh"]
