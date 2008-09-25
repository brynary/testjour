require "drb"
require "cucumber/tree/top_down_visitor"

module Testjour
  
  class QueueingExecutor < ::Cucumber::Tree::TopDownVisitor
    attr_reader :step_count
  
    class << self
      attr_accessor :queue
    end

    def initialize(formatter, step_mother)
      @queue_server = self.class.queue
      @step_count = 0
    end
    
    def wait_for_results
      errors = []
      
      step_count.times do
        dot, message, backtrace = @queue_server.take_result
        
        unless message.size.zero?
          errors << [message, backtrace]
        end
        
        print dot
        $stdout.flush
      end
      
      puts
      error_count = 0
      
      errors.each_with_index do |error, i|
        message, backtrace = error
        
        puts
        puts "#{i+1})"
        puts message
        puts backtrace
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