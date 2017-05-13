# Zookeeper tests
oc exec zoo-0 -- /opt/zookeeper/bin/zkCli.sh create /foo bar;
oc exec zoo-2 -- /opt/zookeeper/bin/zkCli.sh get /foo;

# List topics
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --list

# Create topic
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic kafka-extract30 --create --partitions 30 --replication-factor 2
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic kafka-transform30 --create --partitions 30 --replication-factor 2
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic kafka-store30 --create --partitions 30 --replication-factor 2

oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic test2 --create --partitions 12 --replication-factor 1
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic test32-1replica --create --partitions 32 --replication-factor 1
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic test32-2replica --create --partitions 32 --replication-factor 2
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic testFwd-1replica --create --partitions 32 --replication-factor 1

# Set one of your terminals to listen to messages on the test topic
oc exec -ti kafka-client -- ./bin/kafka-console-consumer.sh --zookeeper zookeeper:2181 --topic test2 --from-beginning

# Go ahead and produce messages
echo "Write a message followed by enter, exit using Ctrl+C"
oc exec -ti kafka-client -- ./bin/kafka-console-producer.sh --broker-list kafka-0.broker.kafkatest.svc.cluster.local:9092 --topic test1

# Bootstrap even if two nodes are down (shorter name requires same namespace)
oc exec -ti kafka-client -- ./bin/kafka-console-producer.sh --broker-list kafka-0.broker:9092,kafka-1.broker:9092,kafka-2.broker:9092 --topic test1

# The following commands run in the pod
oc exec -ti kafka-client -- /bin/bash

# Topic 2, replicated
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --describe --topic test2

./bin/kafka-verifiable-consumer.sh \
  --broker-list=kafka-0.broker.kafkatest.svc.cluster.local:9092,kafka-1.broker.kafkatest.svc.cluster.local:9092 \
  --topic=test2 --group-id=A --verbose

# If a topic isn't available this producer will tell you
# WARN Error while fetching metadata with correlation id X : {topicname=LEADER_NOT_AVAILABLE}
# ... but with current config Kafka will auto-create the topic
./bin/kafka-verifiable-producer.sh \
  --broker-list=kafka-0.broker.kafkatest.svc.cluster.local:9092,kafka-1.broker.kafkatest.svc.cluster.local:9092 \
  --value-prefix=1 --topic=test2 \
  --acks=1 --throughput=1 --max-messages=10

oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic kafka-extract30 --create --partitions 30 --replication-factor 2
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic kafka-transform30 --create --partitions 30 --replication-factor 2
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic kafka-store30 --create --partitions 30 --replication-factor 2

oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --alter --topic kafka-extract30 --config retention.bytes=1073741824
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --alter --topic kafka-extract30 --config retention.ms=1000000
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --alter --topic kafka-extract30 --config compression.type=producer

oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --alter --topic kafka-transform30 --config retention.bytes=1073741824
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --alter --topic kafka-transform30 --config retention.ms=1000000
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --alter --topic kafka-transform30 --config compression.type=producer

oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --alter --topic kafka-store30 --config retention.bytes=1073741824
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --alter --topic kafka-store30 --config retention.ms=1000000
oc exec -n kafkatest kafka-client -- ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --alter --topic kafka-store30 --config compression.type=producer

