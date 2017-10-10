FROM fabric8/s2i-java

ENV ZOO_USER=jboss \
    ZOO_CONF_DIR=/conf \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_PORT=2181 \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2

USER root

# Make directories and assign permissions
RUN mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" \
    && chown "$ZOO_USER:root" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" \
    && chmod -R "g+rwX" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR"

ARG DISTRO_NAME=zookeeper-3.4.9

# Download Apache Zookeeper, untar and clean up
RUN set -x \
    && curl -SLsO "http://www.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz" \
    && tar -xzf "$DISTRO_NAME.tar.gz" -C /opt \
    && mv "/opt/$DISTRO_NAME/conf/"* "$ZOO_CONF_DIR" \
    && rm -r "$DISTRO_NAME.tar.gz" \
	&& yum install -y hostname \
    && mkdir -p /deployments/bin

WORKDIR /opt/$DISTRO_NAME
VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR", "$ZOO_CONF_DIR"]

EXPOSE 2181 2888 3888 8778 5555

ENV PATH=$PATH:/opt/$DISTRO_NAME/bin \
    ZOOCFGDIR=$ZOO_CONF_DIR

COPY run.sh /deployments/bin

# Forcing timezone to UTC
RUN unlink /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime

RUN chown -R "$ZOO_USER:root" "/deployments" "/opt/$DISTRO_NAME" \    
    && chmod -R "g+rwX" "/deployments" "/opt/$DISTRO_NAME" \
    && chmod +x /deployments/bin/run.sh \
    && chown "$ZOO_USER:root" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" \
    && chmod -R "g+rwX" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR"

# Install jmx_prometheus_javaagent
ENV PROMETHEUS_EXPORTER_VERSION=0.10

RUN mkdir -p /opt/jmx_exporter/conf \
    && curl "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${PROMETHEUS_EXPORTER_VERSION}/jmx_prometheus_javaagent-${PROMETHEUS_EXPORTER_VERSION}.jar" \
          -o /opt/jmx_exporter/jmx_prometheus_javaagent.jar \
    && chmod 444 /opt/jmx_exporter/jmx_prometheus_javaagent.jar \
    && chmod 444 /opt/jmx_exporter/conf

ENV PROMETHEUS_EXPORTER_CONF="-javaagent:/opt/jmx_exporter/jmx_prometheus_javaagent.jar=5555:/opt/jmx_exporter/conf/jmx_exporter.yaml"
ADD jmx_exporter.yaml /opt/jmx_exporter/conf/
    
USER $ZOO_USER

CMD ["/usr/local/s2i/run", "zkServer.sh", "start-foreground"]
