module Testjour
module Commands

  class Command
    
    def initialize(args = [], out_stream = STDOUT, err_stream = STDERR)
      @args = args
      @out_stream = out_stream
      @err_stream = err_stream
    end
    
  end
  
end
end