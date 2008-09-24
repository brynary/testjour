require "thread"
require "drb"
require "timeout"
require "systemu"

module Testjour
  
  class SlaveServer

    def self.start
      server = new
      DRb.start_service(nil, server)
      puts "Starting SlaveServer available at #{DRb.uri}"
      puts
      DRb.uri.split(":").last.to_i
    end

    def self.stop
      DRb.stop_service
    end
  
    def run(queue_server_url)
      puts "Running tests from QueueServer: #{queue_server_url}"
    
      Thread.new do
        Thread.current.abort_on_exception = true
        systemu "runner #{queue_server_url}"
      end
    end

  end
  
end