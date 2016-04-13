# Helper functions
def get_zookeeper_id(n)
  if n.attribute?(:zookeeper)
    if n.zookeeper.attribute?(:id)
      return n.zookeeper.id
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

# Install zookeeper
include_recipe 'zookeeper::install'

# Select current zookeeper.id or assign new
this_node = search( :node, "fqdn:#{node.fqdn}" )[0]
z_nodes_list = search( :node, "role:zookeeper_node AND -fqdn:#{node.fqdn}" ).sort
zookeeper_ids = []
current_zookeeper_id = get_zookeeper_id(this_node)
puts yellow("Current zookeeper_id:#{current_zookeeper_id}")
z_nodes_list.each do |z_host|
  z_host_zookeeper_id = get_zookeeper_id(z_host)
  if z_host_zookeeper_id > 0
    zookeeper_ids[zookeeper_ids.size] = z_host_zookeeper_id
  end
end
if current_zookeeper_id < 0 || zookeeper_ids.include?(current_zookeeper_id)
  i = 1
  while zookeeper_ids.include?(i) do
    i += 1
  end
  node.default.zookeeper.id = i
  puts yellow("New zookeeper_id chosen:#{i}")
else
  node.default.zookeeper.id = current_zookeeper_id
end

# Create zookeeper.id file
file 'zookeeper id' do
  path "#{node[:zookeeper][:config][:dataDir]}/myid"
  content "#{node[:zookeeper][:id]}"
  mode '0644'
  owner node[:zookeeper][:user]
  group node[:zookeeper][:user]
end

# Update servers information
node.default[:zookeeper][:config]["server.#{node.zookeeper.id}"] = "0.0.0.0:2888:3888"
z_nodes_list.each do |z_host|
  node.default[:zookeeper][:config]["server.#{get_zookeeper_id(z_host)}"] = "#{z_host.fqdn}:2888:3888"
end
puts yellow("Zookeeper config:#{node[:zookeeper][:config]}")

# Render config
zookeeper_config 'zookeeper config' do
  path "#{node[:zookeeper][:config_dir] % { zookeeper_version: node[:zookeeper][:version] }}/" \
         "#{node[:zookeeper][:conf_file]}"
  config node[:zookeeper][:config]
  user node[:zookeeper][:user]
  action :render
  notifies :restart, 'service[zookeeper]', :delayed
end

# Start zookeeper service
include_recipe 'zookeeper::service'
