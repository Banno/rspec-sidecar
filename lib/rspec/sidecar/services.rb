require 'zk'
require 'json'
require 'timeout'
require 'socket'

module RSpec::Sidecar::Services
  def service_host(name, type)
    service(name, type)["address"]
  end

  def service_port(name, type)
    service(name, type)["port"]
  end

  def service_port_open?(name, type, timeout: 1)
    instance = service(name, type)
    Timeout.timeout(timeout) do
      begin
        TCPSocket.new(instance["address"], instance["port"]).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
        false
      end
    end
  rescue Timeout::Error
    return false
  end

  def service(name, type,
              zookeeper_host: ENV["ZOOKEEPER_PORT_2181_TCP_ADDR"] || "localhost",
              zookeeper_port: ENV["ZOOKEEPER_PORT_2181_TCP_PORT"] || 2181,
              retries: 30)
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
