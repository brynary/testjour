require 'socket'
require 'English'
require 'cucumber/formatter/console'
require 'testjour/result'

module Testjour

  class HttpFormatter < ::Cucumber::Ast::Visitor

    def initialize(step_mother, io, queue_uri)
      super(step_mother)
      @queue_uri = queue_uri
    end

    def visit_multiline_arg(multiline_arg)
      @multiline_arg = true
      super
      @multiline_arg = false
    end

    def visit_step(step)
      step_start = Time.now
      super

      if step.respond_to?(:status)
        progress(Time.now - step_start, step)
      end
    end

    def visit_table_cell_value(value, status)
      if (status != :skipped_param) && !@multiline_arg
        progress(0.0, nil, status)
      end
    end

  private

    def progress(time, step_invocation, status = nil)
      HttpQueue.with_queue(@queue_uri) do |queue|
        queue.push(:results, Result.new(time, step_invocation, status))
      end
    end

  end

end