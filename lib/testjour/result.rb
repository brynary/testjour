require "English"
require "socket"

module Testjour
  
  class Result
    attr_reader :time
    attr_reader :status
    attr_reader :message
    attr_reader :backtrace
    attr_reader :backtrace_line
    
    CHARS = {
      :undefined => 'U',
      :passed    => '.',
      :failed    => 'F',
      :pending   => 'P',
      :skipped   => 'S'
    }
    
    def initialize(time, step_invocation, status = nil)
      @time           = time
      
      if status
        @status = status
      else
        @status         = step_invocation.status
        @backtrace_line = step_invocation.backtrace_line
      
        if step_invocation.exception
          @message    = step_invocation.exception.message.to_s
          @backtrace  = step_invocation.exception.backtrace.join("\n")
        end
      end
      
      @pid        = $PID
      @hostname   = Socket.gethostname
    end
    
    def server_id
      "#{@hostname} [#{@pid}]"
    end
    
    def char
      CHARS[@status]
    end
    
    def failed?
      status == :failed
    end
    
  end
  
end