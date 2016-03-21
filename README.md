## kafka repository

### Requirements

All nodes that are supposed to be managed using this repository must have valid DNS settings and be able to reach each other using FQDN.

### Launch

Before start adding new Kafka servers there should be at least one ZooKeeper server that will maintain Kafka cluster.
For this reason, be sure to add "zookeeper_node" to one or more Chef-managed nodes and wait for chef-client run.

Start adding role "kafka_node" to Chef-managed nodes.
It is not mandatory, but recommended to avoid simultaneous provision of Kafka nodes.
General recommendation is: add role "kafka_node" to new server, wait for successful ending of chef-client run on that server, add role "kafka_node" to next server, etc.

### How to test

##### Create new topic.

Ssh into any of your Kafka servers.
Use your zookeeper server FQDN and replication factor that is less or equal to the number of Kafka nodes in a cluster.

``` sh
cd /opt/kafka
bin/kafka-topics.sh --create --zookeeper zookeeper.example.com:2181 --replication-factor 3 --partitions 1 --topic test
```

##### Send some messages.

Start producer on the same server and type some messages.

``` sh
bin/kafka-console-producer.sh --broker-list this-server-fqdn.example.com:9092 --topic test
This is a message
This is another message
```

##### Start a consumer

Ssh into another Kafka server and start consumer.

``` sh
cd /opt/kafka
bin/kafka-console-consumer.sh --zookeeper zookeeper.example.com:2181 --topic test --from-beginning
```

You will see the output:
```
This is a message
This is another message
```
