require 'cucumber/ast/visitor'

module Testjour
  
    class StepCounter < Cucumber::Ast::Visitor
      attr_reader :backtrace_lines
      
      def initialize(step_mother)
        super
        @backtrace_lines = []
      end
      
      def visit_step(step_invocation)
        unless step_invocation.status == :outline
          @backtrace_lines << step_invocation.backtrace_line
        end
      end
      
      def count
        @backtrace_lines.size
      end
      
    end

end