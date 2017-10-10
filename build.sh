#! /bin/bash

minikube start

docker build docker-kafka -t nbogojevic/kafka -f docker-kafka/Dockerfile
docker build docker-zookeeper -t nbogojevic/zookeeper -f docker-zookeeper/Dockerfile 

helm init
helm install kafka-cluster
