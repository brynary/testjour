require 'cucumber/ast/visitor'

module Testjour

    class StepCounter
      attr_reader :backtrace_lines

      def initialize
        @backtrace_lines = []
      end

      def before_step(step_invocation)
        if step_invocation.respond_to?(:status) #&& step_invocation.status != :outline
          @backtrace_lines << step_invocation.backtrace_line
        end
      end

      def table_cell_value(value, status)
        # Testjour.logger.info "#{value.inspect}, #{status.inspect}"
        @backtrace_lines << "Table cell value: #{value}" unless status == :skipped_param
      end

      def count
        @backtrace_lines.size
      end

    end

end