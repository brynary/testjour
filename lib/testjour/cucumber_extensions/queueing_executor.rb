require "testjour/colorer"
require "testjour/progressbar"

module Testjour
  
  class QueueingExecutor < ::Cucumber::Tree::TopDownVisitor
    attr_reader :step_count
    attr_accessor :formatter
    
    class << self
      attr_accessor :queue
    end

    class ResultsFormatter
      def initialize(step_count)
        @passed  = 0
        @skipped = 0
        @pending = 0
        @result_uris = []
        @errors  = []
        @progress_bar = ProgressBar.new("0 slaves", step_count)
      end
      
      def result(uri, dot, message, backtrace)
        @result_uris << uri
        @result_uris.uniq!
        
        log_result(uri, dot, message, backtrace)
        
        @progress_bar.colorer = colorer
        @progress_bar.title = title
        @progress_bar.inc
      end
      
      def log_result(uri, dot, message, backtrace)
        case dot
        when "."
          @passed += 1
        when "F"
          @errors << [message, backtrace]

          erase_current_line
          print Testjour::Colorer.failed("#{@errors.size}) ")
          puts Testjour::Colorer.failed(message)
          puts backtrace
          puts
        when "P"
          @pending += 1
        when "_"
          @skipped += 1
        end
      end

      def colorer
        if failed?
          Testjour::Colorer.method(:failed).to_proc
        else
          Testjour::Colorer.method(:passed).to_proc
        end
      end
      
      def title
        if failed?
          "#{@result_uris.size} slaves, #{@errors.size} failures"
        else
          "#{@result_uris.size} slaves"
        end
      end
      
      def erase_current_line
        print "\e[K"
      end

      def print_summary
        puts
        puts
        puts Colorer.passed("#{@passed} steps passed")      unless @passed.zero?
        puts Colorer.failed("#{@errors.size} steps failed") unless @errors.empty?
        puts Colorer.skipped("#{@skipped} steps skipped")   unless @skipped.zero?
        puts Colorer.pending("#{@pending} steps pending")   unless @pending.zero?
        puts
      end
      
      def finish
        @progress_bar.finish
        print_summary
      end
      
      def failed?
        @errors.any?
      end
    end
    
    def initialize(queue_server, step_mother)
      @queue_server = queue_server
      @step_count = 0
    end
    
    def wait_for_results
      results_formatter = ResultsFormatter.new(@step_count)
      step_count.times do
        results_formatter.result(*@queue_server.take_result)
      end
      results_formatter.finish
    end
    
    def visit_feature(feature)
      super
      @queue_server.write_work(feature.file)
    end

    def visit_row_scenario(scenario)
      visit_scenario(scenario)
    end
    
    def visit_regular_scenario(scenario)
      visit_scenario(scenario)
    end
    
    def visit_row_step(step)
      visit_step(step)
    end
    
    def visit_regular_step(step)
      visit_step(step)
    end
    
    def visit_step(step)
      @step_count += 1
    end
    
    def method_missing(*args)
      # Do nothing
    end

  end
  
end