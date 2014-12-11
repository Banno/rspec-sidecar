require 'timeout'

module RSpec::Sidecar::WaitUntil
  def wait_until(timeout: 30, &blk)
    Timeout.timeout(timeout) do
      loop do
        if value = yield
          break value
        else
          sleep(1)
        end
      end
    end
  end
end
