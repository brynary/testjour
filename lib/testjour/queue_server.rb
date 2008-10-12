require "thread"
require "drb"
require "timeout"

module Testjour

  class QueueServer
    TIMEOUT_IN_SECONDS = 60
  
    def self.with_server
      server = new
      DRb.start_service(nil, server)
      yield server
    end

    def self.stop
      DRb.stop_service
    end

    def initialize
      reset
    end

    def reset
      @work_queue   = Queue.new
      @result_queue = Queue.new
      @error_queue  = Queue.new
    end
  
    def done_with_work
      @done_with_work = true
    end
    
    def take_result
      Timeout.timeout(TIMEOUT_IN_SECONDS, ResultOverdueError) do
        @result_queue.pop
      end
    end

    def take_work
      raise NoWorkUnitsRemainingError if @done_with_work

      @work_queue.pop(true)
    rescue Object => ex
      if ex.message == "queue empty"
        raise NoWorkUnitsAvailableError
      else
        raise
      end
    end
    
    def write_result(dot, message = nil, backtrace = [])
      @result_queue.push [dot, message.to_s, backtrace.join("\n")]
      nil
    end

    def write_work(work_unit)
      @work_queue.push work_unit
      nil
    end

    class NoWorkUnitsAvailableError < StandardError; end
    class NoWorkUnitsRemainingError < StandardError; end
    class ResultOverdueError < StandardError; end
  end
  
end