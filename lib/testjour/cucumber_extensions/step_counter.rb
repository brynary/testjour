require 'cucumber/ast/visitor'

module Testjour

    class StepCounter < Cucumber::Ast::Visitor
      attr_reader :backtrace_lines

      def initialize(step_mother)
        super
        @backtrace_lines = []
      end

      def visit_step(step_invocation)
        if step_invocation.respond_to?(:status) #&& step_invocation.status != :outline
          @backtrace_lines << step_invocation.backtrace_line
        end
      end

      def visit_table_cell_value(value, status)
        # Testjour.logger.info "#{value.inspect}, #{status.inspect}"
        super
        @backtrace_lines << "Table cell value: #{value}" unless status == :skipped_param
      end

      def count
        @backtrace_lines.size
      end

    end

end