require "drb"

class DRbFormatter
  
  def initialize(ro)
    @ro = ro
    # @errors = []
  end
  
  def step_passed(step, regexp, args)
    @ro.write_result "."
  end
  
  def step_failed(step, regexp, args)
    # @errors << step.error
    @ro.write_result "F"
  end
  
  def step_pending(step, regexp, args)
    @ro.write_result "P"
  end

  def step_skipped(step, regexp, args)
    @ro.write_result "_"
  end

  def dump
    # @io.puts failed
    # @errors.each_with_index do |error,n|
    #   @io.puts
    #   @io.puts "#{n+1})"
    #   @io.puts error.message
    #   @io.puts error.backtrace.join("\n")
    # end
    # @io.print reset
  end
end