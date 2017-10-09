#!/bin/bash

# Command line arguments given to this script
export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }"
# Use Prometheus exporter if defined
if [ ! -z "$PROMETHEUS_EXPORTER_CONF" ]; then
    if [ -f /opt/jmx_exporter/conf/jmx_exporter.yaml ]; then
        export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }${PROMETHEUS_EXPORTER_CONF}"
    fi
fi
# Add jolokia or agent bond
if [ -f /opt/agent-bond-opts ]; then
    export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }$(agent-bond-opts)"
elif [ -f /opt/agentbond/agent-bond-opts ]; then
    export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }$(/opt/agentbond/agent-bond-opts)"
elif [ -f /opt/jolokia/jolokia-opts ]; then
    export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }$(/opt/jolokia/jolokia-opts)"
fi

if [ ! -z "$KAFKA_ADVERTISED_HOST" ]; then
    echo "advertised host: $KAFKA_ADVERTISED_HOST"
    if grep -q "^advertised.host.name" config/server.properties; then
        sed -r -i "s/#(advertised.host.name)=(.*)/\1=$KAFKA_ADVERTISED_HOST/g" config/server.properties
    else
        echo "advertised.host.name=$KAFKA_ADVERTISED_HOST" >> config/server.properties
    fi
fi
if [ ! -z "$KAFKA_ADVERTISED_PORT" ]; then
    echo "advertised port: $KAFKA_ADVERTISED_PORT"
    if grep -q "^advertised.port" config/server.properties; then
        sed -r -i "s/#(advertised.port)=(.*)/\1=$KAFKA_ADVERTISED_PORT/g" config/server.properties
    else
        echo "advertised.port=$KAFKA_ADVERTISED_PORT" >> config/server.properties
    fi
fi

bin/kafka-server-start.sh config/server.properties --override broker.id=$(hostname | awk -F'-' '{print $2}')

