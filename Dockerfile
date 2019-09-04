FROM maven:3.6.1-jdk-8 as builder

WORKDIR /build
RUN git clone https://github.com/Evolveum/midpoint \
  && cd midpoint \
  && git checkout master

WORKDIR /build/midpoint
RUN mvn dependency:resolve

ARG REVISION=master
RUN git pull && git checkout $REVISION

RUN mvn package -DskipTests=true -Dmaven.javadoc.skip=true
RUN mv gui/admin-gui/target/midpoint-executable.war /build/midpoint.war \
  && git rev-parse HEAD > /build/VERSION.txt


FROM ubuntu:18.04

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
RUN apt-get update -y
RUN apt-get install -y openjdk-8-jdk-headless ttf-dejavu tzdata

ENV MP_DIR /opt/midpoint
RUN mkdir -p ${MP_DIR}/var && mkdir -p ${MP_DIR}/lib

COPY --from=builder /build/midpoint.war ${MP_DIR}/lib/
COPY --from=builder /build/VERSION.txt ${MP_DIR}/

EXPOSE 8080

