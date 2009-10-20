module Testjour

    class StepCounter
      attr_reader :backtrace_lines

      def initialize
        @backtrace_lines = []
      end

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        @backtrace_lines << step_match.backtrace_line
      end

      def before_outline_table(outline_table)
        @outline_table = outline_table
      end

      def after_outline_table(outline_table)
        @outline_table = nil
      end

      def table_cell_value(value, status)
        return unless @outline_table
        @backtrace_lines << "Table cell value: #{value}" unless table_header_cell?(status)
      end

      def count
        @backtrace_lines.size
      end

    private

      def table_header_cell?(status)
        status == :skipped_param
      end

    end

end