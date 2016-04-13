node.default['java']['jdk_version'] = '7'

node.default[:zookeeper][:config] = {
  clientPort: 2181,
  dataDir: '/var/lib/zookeeper',
  tickTime: 2000,
  initLimit: 5,
  syncLimit: 2
}
