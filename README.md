# Updated for OpenShift 3.4

Original source code is at: https://github.com/Yolean/kubernetes-kafka

# Kafka as Kubernetes StatefulSet

Example of three Kafka brokers depending on five Zookeeper instances.

To get consistent service DNS names `kafka-N.broker.kafka`(`.svc.cluster.local`), run everything in a single [namespace](http://kubernetes.io/docs/admin/namespaces/walkthrough/).

## Set up volume claims

You may add [storage class](http://kubernetes.io/docs/user-guide/persistent-volumes/#storageclasses)
to the kafka StatefulSet declaration to enable automatic volume provisioning.

Alternatively create [PV](http://kubernetes.io/docs/user-guide/persistent-volumes/#persistent-volumes)s and [PVC](http://kubernetes.io/docs/user-guide/persistent-volumes/#persistentvolumeclaims)s manually. For example in Minikube.

```
./bootstrap/pv.sh
oc create -f ./bootstrap/pvc.yml
# check that claims are bound
oc get pvc
```

## Zookeeper

Zookeeper runs as a [Stateful Set].

If you lose your zookeeper cluster, kafka will be unaware that persisted topics exist.
The data is still there, but you need to re-create topics.

## Start Kafka & Zookeeper

Assuming you have your PVCs `Bound`, or enabled automatic provisioning (see above), you can use kafka in persistent mode:
```
oc process -f kafka-persistent-template.yaml | oc create -f -
```

You can also run kafka in ephemeral storage mode. In this case you rely on kafka replication for data availability.
```
oc process -f kafka-ephemeral-template.yaml | oc create -f -
```

You might want to verify in logs that Kafka found its own DNS name(s) correctly. Look for records like:
```
oc logs kafka-0 | grep "Registered broker"
# INFO Registered broker 0 at path /brokers/ids/0 with addresses: PLAINTEXT -> EndPoint(kafka-0.broker.kafka.svc.cluster.local,9092,PLAINTEXT)
```

## Testing manually

There's a Kafka pod that doesn't start the server, so you can invoke the various shell scripts.
```
oc create -f kafka-client.yml
```

See `./test/test.sh` for some sample commands.

## Automated test, while going chaosmonkey on the cluster

This is WIP, but topic creation has been automated. Note that as a [Job](http://kubernetes.io/docs/user-guide/jobs/), it will restart if the command fails, including if the topic exists :(
```
oc create -f test/11topic-create-test1.yml
```

Pods that keep consuming messages (but they won't exit on cluster failures)
```
oc create -f test/21consumer-test1.yml
```

## Teardown & cleanup

Testing and retesting... delete the namespace. PVs are outside namespaces so delete them too.
```
oc delete petset -l app=kafka
oc delete all -l app=kafka
oc delete configmap -l app=kafka
oc delete template -l app=kafka
```

## Importing template

Two templates can be imported into openshift using:

```bash
oc create -f kafka-ephemeral-template.yaml 
oc create -f kafka-persistent-template.yaml 
```


## Customizing Kafka

It is possible to customize kafka container to advertise different host and port. This is done by specifying following
two environmnet variables: KAFKA_ADVERTISED_HOST and KAFKA_ADVERTISED_PORT. When they are specified, the kafka
containers will use those values to advertise their address instead of default ones. 
