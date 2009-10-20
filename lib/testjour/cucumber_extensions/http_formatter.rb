require 'socket'
require 'English'
require 'cucumber/formatter/console'
require 'testjour/result'

module Testjour

  class HttpFormatter

    def before_multiline_arg(multiline_arg)
      @multiline_arg = true
    end
    
    def after_multiline_arg(multiline_arg)
      @multiline_arg = false
    end

    def before_step(step)
      @step_start = Time.now
    end
    
    def after_step(step)
      if step.respond_to?(:status)
        progress(Time.now - @step_start, step)
      end
    end

    def table_cell_value(value, status)
      if (status != :skipped_param) && !@multiline_arg
        progress(0.0, nil, status)
      end
    end

  private

    def progress(time, step_invocation, status = nil)
      queue = RedisQueue.new
      queue.push(:results, Result.new(time, step_invocation, status))
    end

  end

end