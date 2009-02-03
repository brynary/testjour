module Testjour
module Commands
    
  class Version
    
    def initialize(out_stream = STDOUT, err_stream = STDERR)
      @out_stream = out_stream
      @err_stream = err_stream
    end
    
    def execute
      @out_stream.puts "testjour 0.3"
    end
    
  end
  
end
end