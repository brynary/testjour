require "systemu"

module Testjour
  module RunCommand
    
    def run_command(cmd)
      pid_queue = Queue.new

      Thread.new do
        Thread.current.abort_on_exception = true
        status, stdout, stderr = systemu(cmd) { |pid| pid_queue << pid }
        Testjour.logger.warn stderr if stderr.strip.size > 0
      end

      pid = pid_queue.pop
      Testjour.logger.info "Started on PID #{pid}: #{cmd}"
      pid
    end
    
  end
end