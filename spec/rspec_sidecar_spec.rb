require 'rspec/sidecar'

describe RSpec::Sidecar do
  it "includes the wait_until helper" do
    result = wait_until { true }
    expect(result).to be true
  end
  
  it "the  wait_until helper will fail if it's always falsy" do
    expect { wait_until(timeout: 2) { false } }.to raise_error
  end
end
