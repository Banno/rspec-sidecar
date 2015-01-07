require 'zk'
require 'rest_client'

module RSpec::Sidecar::AppAvailability
  def app_is_available
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
