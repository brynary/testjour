require "testjour/commands/command"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      testjour_path = File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
      cmd = "#{testjour_path} local:run #{@args.join(' ')}"
      exec cmd
    end
    
  end
  
end
end