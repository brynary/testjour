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
    end
    
    def wait_for_results
      passed  = 0
      skipped = 0
      pending = 0
      errors  = []
      
      step_count.times do
        dot, message, backtrace = @queue_server.take_result
        
        case dot
        when "."
          passed += 1
          print Colorer.passed(dot)
        when "F"
          errors << [message, backtrace]
          print Colorer.failed(dot)
        when "P"
          pending += 1
          print Colorer.pending(dot)
        when "_"
          skipped += 1
          print Colorer.skipped(dot)
        else
          print dot
        end
        
        $stdout.flush
      end
      
      puts
      puts
      puts Colorer.passed("#{passed} steps passed") unless passed.zero?
      puts Colorer.failed("#{errors.size} steps failed") unless errors.empty?
      puts Colorer.skipped("#{skipped} steps skipped") unless skipped.zero?
      puts Colorer.pending("#{pending} steps pending") unless pending.zero?
      puts
      
      errors.each_with_index do |error, i|
        message, backtrace = error
        
        puts
        puts Colorer.failed("#{i+1})")
        puts Colorer.failed(message)
        puts Colorer.failed(backtrace)
      end
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