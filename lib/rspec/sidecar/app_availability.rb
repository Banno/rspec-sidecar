require 'zk'
require 'rest-client'

module RSpec::Sidecar::AppAvailability
  def app_is_available?(&blk)
    begin
      yield
    rescue Errno::ECONNREFUSED => _
      false
    rescue RestClient::ServiceUnavailable => _
      false
    rescue ZK::Exceptions::NoNode => _
      false
    end
  end
end
