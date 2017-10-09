#!/bin/bash

set -e

# Add jolokia agent support
export SERVER_JVMFLAGS="${SERVER_JVMFLAGS:+${SERVER_JVMFLAGS} }"
if [ -f agent-bond-opts ]; then
    export SERVER_JVMFLAGS="${SERVER_JVMFLAGS:+${SERVER_JVMFLAGS} }$(agent-bond-opts)"
elif [ -f /opt/agentbond/agent-bond-opts ]; then
    export SERVER_JVMFLAGS="${SERVER_JVMFLAGS:+${SERVER_JVMFLAGS} }$(/opt/agentbond/agent-bond-opts)"
elif [ -f /opt/jolokia/jolokia-opts ]; then
    export SERVER_JVMFLAGS="${SERVER_JVMFLAGS:+${SERVER_JVMFLAGS} }$(/opt/jolokia/jolokia-opts)"
fi

# Allow the container to be started with `--user`
if [ "$1" = 'zkServer.sh' -a "$(id -u)" = '0' ]; then
    chown -R "$ZOO_USER" "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR"
    exec su-exec "$ZOO_USER" "$0" "$@"
fi

# Generate the config only if it doesn't exist
if [ ! -f "$ZOO_CONF_DIR/zoo.cfg" ]; then
    CONFIG="$ZOO_CONF_DIR/zoo.cfg"

    echo "clientPort=$ZOO_PORT" >> "$CONFIG"
    echo "dataDir=$ZOO_DATA_DIR" >> "$CONFIG"
    echo "dataLogDir=$ZOO_DATA_LOG_DIR" >> "$CONFIG"

    echo "tickTime=$ZOO_TICK_TIME" >> "$CONFIG"
    echo "initLimit=$ZOO_INIT_LIMIT" >> "$CONFIG"
    echo "syncLimit=$ZOO_SYNC_LIMIT" >> "$CONFIG"

    ZOO_SERVER_COUNT="${ZOO_SERVER_COUNT:-3}"
    # If ZOO_SERVER_COUNT is not defined, assume 3 nodes
    for ((i=1;i<=ZOO_SERVER_COUNT;i++));
    do
        echo "server.$i=zoo-$((i-1)).zoo:2888:3888:participant " >> "$CONFIG"
    done
    # If ZOO_SERVERS is not defined, allocate ZOO_SERVER_COUNT zoo nodes
    #if [ -z $ZOO_SERVERS ]; then
    #    for server in $ZOO_SERVERS; do
    #        echo "$server" >> "$CONFIG"
    #    done
    #fi

fi

# Write myid only if it doesn't exist                                                                                                                                                                                                                                                
if [ ! -f "$ZOO_DATA_DIR/myid" ]; then                                                                                                                                                                                                                                               
    if [ -z "$ZOO_MY_ID" ]; then                                                                                                                                                                                                                                                     
        ZOO_MY_ID=$(($(hostname | sed s/.*-//) + 1))                                                                                                                                                                                                                                 
        echo "Guessed server id: $ZOO_MY_ID"                                                                                                                                                                                                                                         
        # Tries to bind to it's own server entry, which won't work with names ("Exception while listening java.net.SocketException: Unresolved address")                                                                                                                             
        sed -i s/server\.$ZOO_MY_ID\=[a-z0-9.-]*/server.$ZOO_MY_ID=0.0.0.0/ "$ZOO_CONF_DIR/zoo.cfg"                                                                                                                                                                                  
    fi                                                                                                                                                                                                                                                                               
    echo "${ZOO_MY_ID:-1}" > "$ZOO_DATA_DIR/myid"                                                                                                                                                                                                                                    
fi                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                     
          
exec "$@"