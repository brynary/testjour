require "drb"

module Testjour
  
  class QueueingExecutor
    attr_reader :step_count
  
    class << self
      attr_accessor :queue
    end

    def initialize(formatter, step_mother)
      @queue_server = self.class.queue
      @step_count = 0
    end
    
    def wait_for_results
      step_count.times do
        print @queue_server.take_result
        $stdout.flush
      end
    end

    def visit_features(features)
      features.accept(self)
    end

    def visit_feature(feature)
      feature.accept(self)
      @queue_server.write_work(feature.file)
    end

    def visit_row_scenario(scenario)
      visit_scenario(scenario)
    end

    def visit_regular_scenario(scenario)
      visit_scenario(scenario)
    end

    def visit_scenario(scenario)
      scenario.accept(self)
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