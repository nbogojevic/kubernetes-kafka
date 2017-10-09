## Managing Kafka clusters in Kubernetes

### Installing

The installation is done using helm chart:

```bash
helm install kafka-cluster
``` 

### Helm Chart Parameters

```yaml
# imageRegistry is the address of the container image registry to use
# imageRegistry: docker.io
# pullPolicy is the kubernetes policy to use for pulling images: Always, IfNotPresent, Never
pullPolicy: IfNotPresent
# applicationName is the default name of the application
applicationName: kafka-cluster

kafka:
  image: nbogojevic/kafka
  tag: latest
  serviceName: kafka
  dnsName: broker
  nodes: 3
  jvmFlags: -Xmx1G
  storageSize: 2GiB
  persistent: false # Set to true to use persistent volumes
  hawkular: false   # Set to true to enable hawkular metrics
  nodeSelector:     # Node labels can be specified unde this key
  jolokia:
    secured: true
    password: jolokia

zookeeper:
  image: nbogojevic/zookeeper
  tag: latest
#  tag: 3.4.9
  serviceName: zookeeper
  dnsName: zoo
  nodes: 3 
  jvmFlags: -Xmx512m
  hawkular: false   # Set to true to enable hawkular metrics
  nodeSelector:     # Node labels can be specified unde this key
  jolokia:
    secured: true
    password: jolokia
```

## Kafka

### Kafka as Kubernetes StatefulSet

Kafka is run as a Kubernetes StatefulSet (or PetSet in older versions). 

#### Storage
Kafka can be run with or without persitent volumes.


When running with persitent volumes, the data is saved on instance or node crash. When running without persitent volumes, the data is stored locally on the node a kubernetes node loss may result in data loss, so high-availability and resiliency should be supported by kafka mechanisms, e.g. setting replication factor sufficiently high.

As for best performances, one might perfer specific local storage characteristics (SSD), helm chart allows usage of node selector to select instances where kafka would be deployed.  

### Kafka container image

Default kafka container image is based on fabric8/s2i-java image. The docker build is located in `docker-kafka/`.

#### Customizing Kafka

It is possible to customize kafka container to advertise different host and port. This is done by specifying following
two environmnet variables: `KAFKA_ADVERTISED_HOST` and `KAFKA_ADVERTISED_PORT`. When they are specified, the kafka
containers will use those values to advertise their address instead of default ones. 


### Kafka in OpenShift

For details see [openshift/README.md](openshift/README.md)

## Zookeeper

Zookeeper also runs as a Stateful Set.

Zookeeper uses local storage, so if you lose your zookeeper cluster, kafka will be unaware that persisted topics exist.
The data is still there, but you will need to re-create topics. This can be done using `kafka-operator`.

### Zookeeper container image

Default zookeeper container image is based on fabric8/s2i-java image. The docker build is located in `docker-zookeeper/`.

