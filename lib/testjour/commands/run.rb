require "testjour/commands/command"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      @out_stream.puts "Passed"
    end
    
  end
  
end
end