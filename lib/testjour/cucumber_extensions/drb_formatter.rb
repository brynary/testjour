require "drb"

module Testjour
  
  class DRbFormatter
  
    def initialize(queue_server)
      @queue_server = queue_server
    end
  
    def step_passed(step, regexp, args)
      @queue_server.write_result "."
    end
  
    def step_failed(step, regexp, args)
      # @queue_server.write_error(step.error.message, step.error.backtrace)
      @queue_server.write_result "F"
    end
  
    def step_pending(step, regexp, args)
      @queue_server.write_result "P"
    end

    def step_skipped(step, regexp, args)
      @queue_server.write_result "_"
    end
    
    def dump
    end
    
  end
  
end