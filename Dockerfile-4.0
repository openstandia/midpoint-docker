FROM maven:3.6.2-jdk-11 as builder

WORKDIR /build
RUN git clone https://github.com/Evolveum/midpoint \
  && cd midpoint \
  && git checkout support-4.0

WORKDIR /build/midpoint
RUN mvn dependency:resolve

ARG REVISION=f65a92d757bb95bc683c01675312168b0b1e47a0
RUN git pull && git checkout $REVISION

RUN mvn package -DskipTests=true -Dmaven.javadoc.skip=true
RUN mv gui/admin-gui/target/midpoint-executable.war /build/midpoint.war \
  && git rev-parse HEAD > /build/VERSION.txt


FROM alpine:3.10.3

ENV JAVA_HOME /usr/lib/jvm/default-jvm
ENV PATH $PATH:$JAVA_HOME/bin
RUN apk update \
  && apk --no-cache add openjdk11-jdk tzdata \
  && rm -rf /var/cache/apk/*

ENV MP_DIR /opt/midpoint
RUN mkdir -p ${MP_DIR}/var && mkdir -p ${MP_DIR}/lib

COPY --from=builder /build/midpoint.war ${MP_DIR}/lib/
COPY --from=builder /build/VERSION.txt ${MP_DIR}/

EXPOSE 8080

