#!/bin/bash

# Command line arguments given to this script
export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }"

# Add jolokia or agent bond
if [ -f /opt/prometheus/prometheus-opts ]; then
    export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }$(/opt/prometheus/prometheus-opts)"
fi

if [ -f /opt/jolokia/jolokia-opts ]; then
    export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }$(/opt/jolokia/jolokia-opts)"
fi

export KAFKA_PROPERTIES_OVERRIDES="--override broker.id=$(hostname | awk -F'-' '{print $2}')"

bin/kafka-server-start.sh /opt/mounted/config/server.properties ${KAFKA_PROPERTIES_OVERRIDES}

