require 'rspec/sidecar'
require 'socket'

describe RSpec::Sidecar do
  it "includes the wait_until helper" do
    result = wait_until { true }
    expect(result).to be true
  end

  it "the  wait_until helper will fail if it's always falsy" do
    expect { wait_until(timeout: 2) { false } }.to raise_error
  end

  let(:instance_info) { {:address => "host1", :port => "9999"}  }

  it "exposes service_host to look up instance ports" do
    setup_zookeeper_mock("test", "http", instance_info)
    expect(service_host("test", "http")).to eql(instance_info[:address])
  end

  it "exposes service_port to look up instance hosts" do
    setup_zookeeper_mock("test", "http", instance_info)
    expect(service_port("test", "http")).to eql(instance_info[:port])
  end

  it "exposes service_port_open? to see if instances are open and aren't" do
    setup_zookeeper_mock("test", "http", instance_info)
    expect(service_port_open?("test", "http")).to be false
  end

  it "exposes service_port_open? to see if instances are open and are" do
    TCPServer.new(2000)
    setup_zookeeper_mock("test", "http", {address: "localhost", port: 2000})
    expect(service_port_open?("test", "http")).to be true
  end

  it "spins until service instances are available" do
    # multiple calls
    expect(zookeeper).to receive(:children).with("/banno/services/test:http").and_return([], ["child1"])
    
    expect(zookeeper).to receive(:get).with("/banno/services/test:http/child1") do
      [instance_info.to_json, nil]
    end
    
    expect(service_port("test", "http")).to eql(instance_info[:port])
  end

  it "will eventually stop retrying to spin for service instances" do
    allow(zookeeper).to receive(:children) { [] }
    expect { service_port("test", "http") }.to raise_error("service 'test:http' not available")
  end

  it "includes a helper to check if an app is available" do
    result = app_is_available? { true }
    expect(result).to be true
  end

  it "the app_is_available helper fails on a connection refused" do
    result = app_is_available? { raise Errno::ECONNREFUSED }
    expect(result).to be false
  end

  it "the app_is_available helper fails on a service unavailable" do
    result = app_is_available? { raise RestClient::ServiceUnavailable }
    expect(result).to be false
  end

  it "the app_is_available helper fails on a no zookeeper node error" do
    result = app_is_available? { raise ZK::Exceptions::NoNode }
    expect(result).to be false
  end

  let(:zookeeper) do 
    zookeeper = double("zookeeper")
    expect(ZK).to receive(:open).and_yield(zookeeper)
    zookeeper
  end

  private
  def setup_zookeeper_mock(name, type, instance_info)
    expect(zookeeper).to receive(:children).with("/banno/services/#{name}:#{type}") do
      ["child1"]
    end
    expect(zookeeper).to receive(:get).with("/banno/services/#{name}:#{type}/child1") do
      [instance_info.to_json, nil]
    end
  end
end
