require 'socket'
require 'english'
require 'cucumber/formatter/console'
require 'testjour/result'

module Testjour
  
  class HttpFormatter < Cucumber::Ast::Visitor

    def initialize(step_mother, io, queue_uri)
      super(step_mother)
      @queue_uri = queue_uri
    end
    
    def visit_multiline_arg(multiline_arg, status)
      @multiline_arg = true
      super
      @multiline_arg = false
    end
    
    def visit_step(step)
      step_start = Time.now
      super
      
      unless step.status == :outline
        progress(Time.now - step_start, step)
      end
    end

    def visit_table_cell_value(value, width, status)
      if (status != :thead) && !@multiline_arg
        raise "Table cells not supported by testjour yet."
      end
    end
    
  private

    def progress(time, step_invocation)
      HttpQueue.with_queue(@queue_uri) do |queue|
        queue.push(:results, Result.new(time, step_invocation))
      end
    end
    
  end

end