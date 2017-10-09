#! /bin/bash

docker build docker-kafka -f docker-kafka/Dockerfile.s2i -t nbogojevic/kafka
docker build docker-zookeeper -f docker-zookeeper/Dockerfile.s2i -t nbogojevic/zookeeper