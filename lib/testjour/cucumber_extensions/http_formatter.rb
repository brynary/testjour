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
    
    def visit_step_name(keyword, step_name, status, step_definition, source_indent)
      progress(status) unless status == :outline
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

    def progress(status)
      HttpQueue.with_queue do |queue|
        queue.push(:results, CHARS[status])
      end
    end
    
  end

end