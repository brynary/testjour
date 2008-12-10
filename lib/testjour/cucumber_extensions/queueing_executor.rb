require "testjour/colorer"
require "testjour/progressbar"

module Testjour
  
  class QueueingExecutor < ::Cucumber::Tree::TopDownVisitor
    attr_reader :step_count
    attr_accessor :formatter
    
    class << self
      attr_accessor :queue
    end

    def initialize(queue_server, step_mother)
      @queue_server = queue_server
      @step_count = 0
      @passed  = 0
      @skipped = 0
      @pending = 0
      @result_uris = []
      @errors  = []
    end
    
    def wait_for_results
      progress_bar = ProgressBar.new("0 slaves", step_count)
      
      step_count.times do
        log_result(*@queue_server.take_result)
        
        if failed?
          progress_bar.colorer = Testjour::Colorer.method(:failed).to_proc
          progress_bar.title = "#{@result_uris.size} slaves, #{@errors.size} failures"
        else
          progress_bar.colorer = Testjour::Colorer.method(:passed).to_proc
          progress_bar.title   = "#{@result_uris.size} slaves"
        end
        
        progress_bar.inc
      end
      
      progress_bar.finish

      print_summary
    end
    
    def failed?
      @errors.any?
    end
    
    
    def log_result(uri, dot, message, backtrace)
      @result_uris << uri
      @result_uris.uniq!
      
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

    def erase_current_line
      print "\e[K"
    end
    
    def print_summary
      puts
      puts
      puts Colorer.passed("#{@passed} steps passed") unless @passed.zero?
      puts Colorer.failed("#{@errors.size} steps failed") unless @errors.empty?
      puts Colorer.skipped("#{@skipped} steps skipped") unless @skipped.zero?
      puts Colorer.pending("#{@pending} steps pending") unless @pending.zero?
      puts
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