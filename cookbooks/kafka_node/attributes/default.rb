node.default[:java][:jdk_version] = '7'

node.default[:kafka][:version] = '0.9.0.1'
node.default[:kafka][:checksum] = 'db28f4d5a9327711013c26632baed8e905ce2f304df89a345f25a6dfca966c7a'
node.default[:kafka][:md5_checksum] = 'B71E5CBC78165C1CA483279C27402663'
node.default[:kafka][:scala_version] = '2.11'

node.default[:kafka][:broker][:zookeeper][:connect] = 'localhost:2181'
node.default[:kafka][:broker][:port] = '9092'
node.default[:kafka][:broker][:log][:dir] = '/tmp/kafka-logs'
node.default[:kafka][:broker][:delete][:topic][:enable] = true

node.default[:kafka][:automatic_start] = true
node.default[:kafka][:automatic_restart] = true

# List of topics to create.
# Example: node.default[:kafka][:topics_to_create] = ['topic1', 'topic2', 'topic3']
node.default[:kafka][:topics_to_create] = []
