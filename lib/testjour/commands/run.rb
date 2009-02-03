require "testjour/commands/command"
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
      
      status, stdout, stderr = systemu(cmd)
      
      @out_stream.write stdout
      @err_stream.write stderr
      status.exitstatus
    end
    
  end
  
end
end