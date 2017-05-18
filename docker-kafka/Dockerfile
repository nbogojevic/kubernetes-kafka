FROM fabric8/s2i-java


ENV KAFKA_VERSION=0.10.2.0
ENV SCALA_VERSION=2.12.1
ENV KAFKA_BIN_VERSION=2.12-$KAFKA_VERSION

USER root
RUN curl -SLs "http://www.scala-lang.org/files/archive/scala-$SCALA_VERSION.rpm" -o scala.rpm \
        && rpm -ihv scala.rpm \
        && rm scala.rpm \
		&& yum install -y hostname \
        && curl -SLs "http://www.apache.org/dist/kafka/$KAFKA_VERSION/kafka_$KAFKA_BIN_VERSION.tgz" | tar -xzf - -C /opt \
        && mv /opt/kafka_$KAFKA_BIN_VERSION /opt/kafka \
        && mkdir -p /deployments/bin

ADD run.sh /deployments/bin

RUN chown -R jboss:root /deployments /opt/kafka \
    && chmod -R "g+rwX" /deployments /opt/kafka \
    && chmod +x /deployments/bin/run.sh

USER jboss

ADD config/server.properties /opt/kafka/config/

WORKDIR /opt/kafka

EXPOSE 9092 8778

CMD [ "/usr/local/s2i/run", "config/server.properties"]
