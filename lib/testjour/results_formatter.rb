require "testjour/progressbar"
require "testjour/colorer"

module Testjour
  class ResultsFormatter
    def initialize(step_count)
      @passed  = 0
      @skipped = 0
      @pending = 0
      @undefined = 0
      @errors  = []
      @progress_bar = ProgressBar.new("0 failures", step_count)
    end
  
    def result(dot, message = nil, backtrace = nil)
      log_result(dot, message, backtrace)
    
      @progress_bar.colorer = colorer
      @progress_bar.title = title
      @progress_bar.inc
    end
  
    def log_result(dot, message = nil, backtrace = nil)
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
      when "U"
        @undefined += 1
      when "S"
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
      "#{@errors.size} failures"
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
      puts Colorer.failed("#{@undefined} steps undefined")   unless @undefined.zero?
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
end