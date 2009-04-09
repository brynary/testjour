require "English"
require "socket"

module Testjour
  
  class Result
    attr_reader :time
    attr_reader :status
    attr_reader :hostname
    attr_reader :pid
    attr_reader :message
    attr_reader :backtrace
    
    CHARS = {
      :undefined => 'U',
      :passed    => '.',
      :failed    => 'F',
      :pending   => 'P',
      :skipped   => 'S'
    }
    
    def initialize(time, status, exception)
      @time   = time
      @status = status
      
      if exception
        @message    = exception.message.to_s
        @backtrace  = exception.backtrace.join("\n")
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
    
  end
  
end