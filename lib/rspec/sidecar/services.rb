require 'zk'
require 'json'

module RSpec::Sidecar::Services
  def service_host(name, type)
    service(name, type)["address"]
  end

  def service_port(name, type)
    service(name, type)["port"]
  end

  def service(name, type,
              zookeeper_host = ENV["ZOOKEEPER_PORT_2181_TCP_ADDR"] || "localhost",
              zookeeper_port = ENV["ZOOKEEPER_PORT_2181_TCP_PORT"] || 2181,
              retries = 5)
    ZK.open(zookeeper_host + ":" + zookeeper_port.to_s) do |zk|
      instances_path = "/banno/services/#{name}:#{type}"
      loop do
        instances = zk.children(instances_path)
        if instances.empty?
          raise "service '#{name}:#{type}' not available" if retries == 0
          retries -= 1
          
          puts "retrying to get instances for service '#{name}:#{type}' (tries left: #{retries})"
          sleep 1
        else
          instance_json = zk.get(instances_path + "/" + instances[0])[0]
          return JSON.parse(instance_json)
        end
      end
    end
  end
end
