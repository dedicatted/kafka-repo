# Helpers
def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end
def yellow(text); colorize(text, 33); end

# Main
k_nodes_number = search( :node, "role:kafka_node" ).size
command_to_execute = ''
topics = %x[#{node.default.kafka.install_dir}/bin/kafka-topics.sh --list --zookeeper #{node.default.kafka.broker.zookeeper.connect}].split("\n")

node.default.kafka.topics_to_create.each do |topic_to_create|
  if not topics.include?(topic_to_create)
    command_to_execute += "bin/kafka-topics.sh --create --zookeeper #{node.default.kafka.broker.zookeeper.connect} --replication-factor #{k_nodes_number} --partitions 1 --topic #{topic_to_create};"
  end
end
command_to_execute = command_to_execute[0...-1]

execute 'create_topics' do
  cwd "#{node.default.kafka.install_dir}"
  command "#{command_to_execute}"
  not_if { command_to_execute.empty? }
end
