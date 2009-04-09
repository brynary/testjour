module Testjour
  class ResultSet
    
    def initialize(step_counter)
      @step_counter = step_counter
      
      @counts   = Hash.new { |h, result|    h[result]    = 0 }
      @results  = Hash.new { |h, server_id| h[server_id] = [] }
      
      @backtrace_lines_seen = []
    end
    
    def record(result)
      @results[result.server_id] << result
      @counts[result.status] += 1
      @backtrace_lines_seen << result.backtrace_line
    end
    
    def count(result)
      @counts[result]
    end
    
    def each_server_stat(&block)
      @results.sort_by { |server_id, times| server_id }.each do |server_id, results|
        total_time       = total_time(results)
        steps_per_second = results.size.to_f / total_time.to_f
        
        block.call(server_id, results.size, total_time, steps_per_second)
      end
    end
    
    def errors
      @results.values.flatten.select { |r| r.failed? }
    end
    
    def slaves
      @results.keys.size
    end
    
    def missing_backtrace_lines
      @step_counter.backtrace_lines - @backtrace_lines_seen
    end
    
  protected
  
    def total_time(results)
      results.inject(0) { |memo, r| r.time + memo }
    end
    
  end
end