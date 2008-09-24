require "thread"
require "drb"
require "timeout"
require "systemu"

module Testjour
  
  class SlaveServer

    def self.start
      server = new
      DRb.start_service(nil, server)
      DRb.uri.split(":").last.to_i
    end

    def self.stop
      DRb.stop_service
    end
  
    def run(queue_server_url)
      puts "Running tests from QueueServer: #{queue_server_url}"
    
      Thread.new do
        Thread.current.abort_on_exception = true
        
        runner_path = File.expand_path(File.dirname(__FILE__) + "/runner.rb")
        cmd = "#{runner_path} #{queue_server_url}"
        systemu cmd
      end
    end

  end
  
end