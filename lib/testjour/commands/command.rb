module Testjour
module Commands

  class Command
    
    def initialize(out_stream = STDOUT, err_stream = STDERR)
      @out_stream = out_stream
      @err_stream = err_stream
    end
    
  end
  
end
end