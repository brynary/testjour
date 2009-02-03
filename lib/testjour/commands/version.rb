require "testjour/commands/command"

module Testjour
module Commands
    
  class Version < Command
    
    def execute
      @out_stream.puts "testjour 0.3"
    end
    
  end
  
end
end