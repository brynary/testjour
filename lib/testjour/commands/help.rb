require "testjour/commands/command"

module Testjour
module Commands
  
  class Help < Command
  
    def initialize(out_stream = STDOUT, err_stream = STDERR)
      @out_stream = out_stream
      @err_stream = err_stream
    end
  
    def execute
      @out_stream.puts "testjour help:"
    end
  
  end
    
end
end