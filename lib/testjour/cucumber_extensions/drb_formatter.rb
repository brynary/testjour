module Testjour
  
  class DRbFormatter
  
    def initialize(queue_server)
      @queue_server = queue_server
    end
    
    def step_passed(step, regexp, args)
      @queue_server.write_result DRb.uri, "."
    end
  
    def step_failed(step, regexp, args)
      @queue_server.write_result DRb.uri, "F", step.error.message, step.error.backtrace
    end
  
    def step_pending(step, regexp, args)
      @queue_server.write_result DRb.uri, "P"
    end

    def step_skipped(step, regexp, args)
      @queue_server.write_result DRb.uri, "_"
    end
    
    def method_missing(*args, &block)
    end
    
  end
  
end