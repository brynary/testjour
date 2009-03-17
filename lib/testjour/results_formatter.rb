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
      @servers = []
      @progress_bar = ProgressBar.new("0 failures", step_count)
      
      @times = Hash.new { |h,server_id| h[server_id] = [] }
    end
  
    def result(time, hostname, pid, dot, message = nil, backtrace = nil)
      server_id = "#{hostname} [#{pid}]"
      @servers << server_id
      @servers.uniq!
      
      @times[server_id] << time
      
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
      "#{@servers.size} slaves, #{@errors.size} failures"
    end
  
    def erase_current_line
      print "\e[K"
    end

    def print_summary
      puts
      puts
      print_summary_line(:passed)
      puts Colorer.failed("#{@errors.size} steps failed") unless @errors.empty?
      print_summary_line(:skipped)
      print_summary_line(:pending)
      print_summary_line(:undefined)
      puts
      
      @times.sort_by { |server_id, times| server_id }.each do |server_id, times|
        total_time = times.inject(0) { |memo, time| time + memo }
        steps_per_second = times.size.to_f / total_time
        
        puts "#{server_id} ran #{times.size} steps in %.2fs (%.2f steps/s)" % [total_time, steps_per_second]
      end
      
      puts
    end
    
    def print_summary_line(step_type)
      count = instance_variable_get("@#{step_type}")
      puts Colorer.send(step_type, "#{count} steps #{step_type}") unless count.zero?
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