#!/bin/bash

# Command line arguments given to this script
export KAFKA_OPTS="${KAFKA_OPTS:+${KAFKA_OPTS} }$(/opt/jolokia/jolokia-opts)"

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

