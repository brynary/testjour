require 'cucumber/formatter/console'

module Testjour
  
  class HttpFormatter < Cucumber::Ast::Visitor
    include Cucumber::Formatter::Console

    def initialize(step_mother, io, options)
      super(step_mother)
      @io = io
      @options = options
    end
    
    def visit_multiline_arg(multiline_arg, status)
      @multiline_arg = true
      super
      @multiline_arg = false
    end
    
    def visit_step(step)
      exception = step.accept(self)
      
      unless @last_status == :outline
        if @last_status == :failed
          progress(@last_status, exception.message.to_s, exception.backtrace.join("\n"))
        else
          progress(@last_status)
        end
      end
    end
    
    def visit_step_name(keyword, step_name, status, step_definition, source_indent)
      @last_status = status
    end

    def visit_table_cell_value(value, width, status)
      progress(status) if (status != :thead) && !@multiline_arg
    end
    
    private

    CHARS = {
      :undefined => 'U',
      :passed    => '.',
      :failed    => 'F',
      :pending   => 'P',
      :skipped   => 'S'
    }

    def progress(status, message = nil, backtrace = nil)
      HttpQueue.with_queue do |queue|
        queue.push(:results, [CHARS[status], message, backtrace])
      end
    end
    
  end

end