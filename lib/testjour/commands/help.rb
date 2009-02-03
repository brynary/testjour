require "testjour/commands/command"

module Testjour
module Commands
  
  class Help < Command
  
    def execute
      @out_stream.puts "testjour help:"
    end
  
  end
    
end
end