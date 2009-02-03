require "testjour/commands/command"
require "testjour/http_queue"
require "testjour/core_extensions/wait_for_service"
require "systemu"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      testjour_path = File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
      cmd = "#{testjour_path} local:run #{@args.join(' ')}"

      pid = fork do
        exec File.expand_path(File.dirname(__FILE__) + "/../../../bin/httpq")
      end
      
      Process.detach(pid)
      at_exit do
        Process.kill("INT", pid)
      end
      
      TCPSocket.wait_for_service :host => "0.0.0.0", :port => Testjour::HttpQueue.port
      
      status, stdout, stderr = systemu(cmd)
      
      @out_stream.write stdout
      @err_stream.write stderr
      status.exitstatus
    end
    
  end
  
end
end