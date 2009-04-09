require "testjour/progressbar"
require "testjour/colorer"

module Testjour
  class ResultsFormatter
    class ResultsSet
      attr_reader :passed
      attr_reader :skipped
      attr_reader :pending
      attr_reader :undefined
      
      def initialize
        @passed     = 0
        @skipped    = 0
        @pending    = 0
        @undefined  = 0
        
        @results = Hash.new { |h,server_id| h[server_id] = [] }
      end
      
      def record(result)
        @results[result.server_id] << result
        
        case result.char
        when "."
          @passed += 1
        when "P"
          @pending += 1
        when "U"
          @undefined += 1
        when "S"
          @skipped += 1
        end
      end
      
      def results
        @results
      end
      
      def errors
        @results.values.flatten.select { |r| r.char == "F" }
      end
      
      def slaves
        @results.keys.size
      end
      
    end
    
    def initialize(step_count)
      @step_count = step_count
      
      @passed     = 0
      @skipped    = 0
      @pending    = 0
      @undefined  = 0
      
      progress_bar
      @result_set = ResultsSet.new
    end
  
    def result(result)
      @result_set.record(result)
      log_result(result)
      update_progress_bar
    end
    
    def update_progress_bar
      progress_bar.colorer = colorer
      progress_bar.title   = title
      progress_bar.inc
    end
  
    def progress_bar
      @progress_bar ||= ProgressBar.new("0 failures", @step_count)
    end
    
    def log_result(result)
      return unless result.char == "F"
      
      erase_current_line
      print Testjour::Colorer.failed("#{errors.size}) ")
      puts Testjour::Colorer.failed(result.message)
      puts result.backtrace
      puts
    end

    def colorer
      if failed?
        Testjour::Colorer.method(:failed).to_proc
      else
        Testjour::Colorer.method(:passed).to_proc
      end
    end
  
    def title
      "#{@result_set.slaves} slaves, #{errors.size} failures"
    end
  
    def erase_current_line
      print "\e[K"
    end

    def print_summary
      print_summary_line(:passed)
      puts Colorer.failed("#{errors.size} steps failed") unless errors.empty?
      print_summary_line(:skipped)
      print_summary_line(:pending)
      print_summary_line(:undefined)
    end
    
    def print_stats
      @result_set.results.sort_by { |server_id, times| server_id }.each do |server_id, times|
        total_time = times.map { |t| t.time }.inject(0) { |memo, time| time + memo }
        steps_per_second = times.size.to_f / total_time
        
        puts "#{server_id} ran #{times.size} steps in %.2fs (%.2f steps/s)" % [total_time, steps_per_second]
      end
    end
    
    def print_summary_line(step_type)
      count = @result_set.send(step_type)
      puts Colorer.send(step_type, "#{count} steps #{step_type}") unless count.zero?
    end
  
    def finish
      progress_bar.finish
      
      puts
      puts
      print_summary
      puts
      print_stats
      puts
    end
  
    def errors
      @result_set.errors
    end
    
    def failed?
      errors.any?
    end
  end
end