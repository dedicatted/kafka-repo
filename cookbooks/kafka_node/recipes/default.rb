# Helper functions
def get_broker_id(n)
  if n.attribute?(:kafka)
    if n.kafka.attribute?(:broker)
      if n.kafka.broker.attribute?(:broker)
        if n.kafka.broker.broker.attribute?(:id)
          return n.kafka.broker.broker.id
        end
      end
    end
  end
  return -1
end

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end
def yellow(text); colorize(text, 33); end

# Main
include_recipe 'java::default'

this_node = search( :node, "name:#{node.fqdn}" )[0]
current_broker_id = -1
new_broker_id = "undefined"
broker_id_collision = false
current_zookeeper_connect = "undefined"
zookeeper_servers = "undefined"

# Assign unique broker.id
k_nodes_list = search( :node, "role:kafka_node AND -name:#{node.fqdn}" )

kafka_broker_ids = []
current_broker_id = get_broker_id(this_node)
puts yellow("Current broker_id:#{current_broker_id}")
k_nodes_list.each do |k_host|
  k_host_broker_id = get_broker_id(k_host)
  if k_host_broker_id > 0
    kafka_broker_ids[kafka_broker_ids.size] = k_host_broker_id
  end
end
if current_broker_id < 0 || kafka_broker_ids.include?(current_broker_id)
  if kafka_broker_ids.include?(current_broker_id)
    broker_id_collision = true
  end
  i = 1
  while kafka_broker_ids.include?(i) do
    i += 1
  end
  node.default.kafka.broker.broker.id = i
  puts yellow("New broker_id chosen:#{i}")
  new_broker_id = i
else
  node.default.kafka.broker.broker.id = current_broker_id
end


# Assign zookeeper.connect property
z_nodes_list = search( :node, 'role:zookeeper_node' ).sort

if z_nodes_list.empty?
  node.default.kafka.broker.zookeeper.connect = "localhost:2181"
else
  this_node_connect_list = ''
  if this_node.attribute?(:kafka)
    if this_node.kafka.attribute?(:broker)
      if this_node.kafka.broker.attribute?(:zookeeper)
        if this_node.kafka.broker.zookeeper.attribute?(:connect)
          this_node_connect_list = this_node.kafka.broker.zookeeper.connect
        end
      end
    end
  end
  connect_list = ''
  z_nodes_list.each do |z_host|
    if z_host.attribute?(:zookeeper)
      if z_host.zookeeper.attribute?(:config)
        if z_host.zookeeper.config.attribute?(:clientPort)
          connect_list += "#{z_host.fqdn}:#{z_host.zookeeper.config.clientPort},"
        end
      end
    end
  end
  puts yellow("This node zookeeper connect list:#{this_node_connect_list}")
  puts yellow("Zookeeper servers:#{connect_list[0...-1]}")
  current_zookeeper_connect = this_node_connect_list
  zookeeper_servers = connect_list[0...-1]
  node.default.kafka.broker.zookeeper.connect = connect_list[0...-1]
end

file "#{node.kafka.broker.log.dir}/meta.properties" do
  action :delete
  only_if { broker_id_collision }
end

include_recipe 'kafka::default'

# Logging
log 'message' do
  message "Current broker_id:#{current_broker_id}  New broker_id:#{new_broker_id}  Current zookeeper connect:#{current_zookeeper_connect}  Zookeeper servers:#{zookeeper_servers}"
  level :info
end
