require 'zk'
require 'json'
require 'timeout'
require 'socket'

module RSpec::Sidecar::Services

  class SidecarNotAvailable < Exception
  end

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
          retries -= 1
          raise SidecarNotAvailable, "service '#{name}:#{type}' not available" if retries == 0

          puts "retrying to get instances for service '#{name}:#{type}' (tries left: #{retries})"
          sleep 1
        else
          instance_json = zk.get(instances_path + "/" + instances[0])[0]
          return JSON.parse(instance_json)
        end
      end
    end
  end

  def service_is_unregistered(name, type, zookeeper_host: "localhost", zookeeper_port: 2181, retries: 30)
    loop do
      begin
        return false if retries == 0

        service = service(name, type, zookeeper_host: zookeeper_host, zookeeper_port: zookeeper_port, retries: 1)
        retries -= 1
        sleep 1
        puts "waiting for service '#{name}:#{type}' to unregister (tries left: #{retries})"
      rescue SidecarNotAvailable => _
        return true
      end
    end
  end

end
