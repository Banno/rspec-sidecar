require 'rspec/sidecar'

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

  private
  def setup_zookeeper_mock(name, type, instance_info)
    zookeeper = double("zookeeper")
    
    expect(ZK).to receive(:open).and_yield(zookeeper)
    
    expect(zookeeper).to receive(:children).with("/banno/services/#{name}:#{type}") do
      ["child1"]
    end
    expect(zookeeper).to receive(:get).with("/banno/services/#{name}:#{type}/child1") do
      [instance_info.to_json, nil]
    end
  end
end
