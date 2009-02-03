require "testjour/commands/command"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      result = system "cucumber #{@args.first}"
      
      if result
        @out_stream.puts "Passed"
        0
      else
        @out_stream.puts "Failed"
        1
      end
    end
    
  end
  
end
end