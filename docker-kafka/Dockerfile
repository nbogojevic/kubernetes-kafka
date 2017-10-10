FROM fabric8/s2i-java

ENV KAFKA_VERSION=0.11.0.1
ENV SCALA_VERSION=2.12.3-1
ENV KAFKA_BIN_VERSION=2.12-$KAFKA_VERSION

USER root
# Download Scala and Kafka, untar
RUN curl -SLs "http://www.scala-lang.org/files/archive/scala-${SCALA_VERSION}.rpm" -o scala.rpm \
        && rpm -ihv scala.rpm \
        && rm scala.rpm \
		&& yum install -y hostname \
        && curl -SLs "http://www.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${KAFKA_BIN_VERSION}.tgz" | tar -xzf - -C /opt \
        && mv /opt/kafka_${KAFKA_BIN_VERSION} /opt/kafka \
        && mkdir -p /deployments/bin

ADD config/server.properties /opt/kafka/config/

WORKDIR /opt/kafka

EXPOSE 9092 8778 5555

ADD run.sh /deployments/bin

# Set directory and file permissions
RUN chown -R jboss:root /deployments /opt/kafka \
    && chmod -R "g+rwX" /deployments /opt/kafka \
    && chmod +x /deployments/bin/run.sh

# Install jmx_prometheus_javaagent
ENV PROMETHEUS_EXPORTER_VERSION=0.10

RUN mkdir -p /opt/jmx_exporter/conf \
    && curl "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${PROMETHEUS_EXPORTER_VERSION}/jmx_prometheus_javaagent-${PROMETHEUS_EXPORTER_VERSION}.jar" \
          -o /opt/jmx_exporter/jmx_prometheus_javaagent.jar \
    && chmod 444 /opt/jmx_exporter/jmx_prometheus_javaagent.jar \
    && chmod 444 /opt/jmx_exporter/conf

ENV PROMETHEUS_EXPORTER_CONF="-javaagent:/opt/jmx_exporter/jmx_prometheus_javaagent.jar=5555:/opt/jmx_exporter/conf/jmx_exporter.yaml"
ADD jmx_exporter.yaml /opt/jmx_exporter/conf/

USER jboss

CMD [ "/usr/local/s2i/run", "config/server.properties"]
