FROM maven:3.8.2-openjdk-11-slim AS MVN_BUILD

COPY pom.xml /build/
COPY src /build/src/
COPY settings.xml /root/.m2/

WORKDIR /build/

RUN mvn -Dmaven.test.skip=true package

FROM open-liberty:21.0.0.3-full-java11-openj9

USER root
RUN apt-get update && apt-get upgrade -y e2fsprogs libgnutls30 libgcrypt20 libsasl2-2
USER 1001

COPY --chown=1001:0 --from=MVN_BUILD /build/src/main/liberty/config/ /config/
COPY --chown=1001:0 --from=MVN_BUILD /build/src/main/resources/security/ /config/resources/security/
COPY --chown=1001:0 --from=MVN_BUILD /build/target/*.war /config/apps/
COPY --chown=1001:0 --from=MVN_BUILD /build/target/jdbc/* /config/jdbc/
RUN configure.sh
