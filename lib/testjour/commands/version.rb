require "testjour/commands/command"

module Testjour
module Commands
    
  class Version < Command
    
    def execute
      @out_stream.puts "testjour #{VERSION}"
    end
    
  end
  
end
end