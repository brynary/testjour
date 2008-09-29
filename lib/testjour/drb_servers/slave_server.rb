require "thread"
require "drb"
require "timeout"
require "systemu"

module Testjour
  
  class SlaveServer

    def self.start
      server = new
      DRb.start_service(nil, server)
      DRb.uri.split(":").last.to_i
    end

    def self.stop
      DRb.stop_service
    end
  
    def run(queue_server_url, path = nil)
      if running?
        Testjour.logger.info "Not running because pid exists: #{@pid}"
        return false
      end
      
      pid_queue = Queue.new
      @pid = nil
      
      Thread.new do
        Thread.current.abort_on_exception = true
        
        testour_bin_path = File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
        cmd = "#{testour_bin_path} slave:run --queue #{queue_server_url} --chdir #{File.expand_path(".")}".strip
        Testjour.logger.debug "Starting runner with command: #{cmd}"
        status, stdout, stderr = systemu(cmd) { |pid| pid_queue << pid }
        Testjour.logger.warn stderr if stderr.strip.size > 0
      end
      
      @pid = pid_queue.pop
      
      Testjour.logger.info "Running tests from queue #{queue_server_url} on PID #{@pid}"
      
      return @pid
    end
    
  protected
    
    def running?
      return false unless @pid
      Process::kill 0, @pid.to_s.to_i
      true
    rescue Errno::ESRCH, Errno::EPERM
      false
    end
    
  end
  
end