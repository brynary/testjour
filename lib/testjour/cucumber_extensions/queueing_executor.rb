require "drb"

class QueueingExecutor
  attr_reader :failed
  attr_reader :step_count
  
  class << self
    attr_accessor :queue
  end
  
  def line=(line)
  end

  def initialize(formatter, step_mother)
    @ro = self.class.queue
    @step_count = 0
  end
  
  def register_world_proc(&proc)
  end

  def register_before_proc(&proc)
  end

  def register_after_proc(&proc)
  end

  def visit_features(features)
    features.accept(self)
  end

  def visit_feature(feature)
    feature.accept(self)
    @ro.write_work(feature.file)
  end

  def visit_header(header)
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

end