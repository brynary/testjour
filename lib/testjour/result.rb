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

    def initialize(time, status, step_match = nil, exception = nil)
      @time   = time
      @status = status

      if step_match
        @backtrace_line = step_match.backtrace_line
      end

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

    def failed?
      status == :failed
    end

    def undefined?
      status == :undefined
    end

  end

end