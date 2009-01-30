require "thread"
require "drb"
require "uri"
require "timeout"

require "testjour/run_command"

module Testjour
  
  class SlaveServer
    include RunCommand
    
    def self.start
      server = self.new
      DRb.start_service(nil, server)
      uri = URI.parse(DRb.uri)
      return uri.port.to_i
    end

    def self.stop
      DRb.stop_service
    end
  
    def status
      running? ? "busy" : "available"
    end
    
    def warm(queue_server_url)
      if running?
        Testjour.logger.info "Not running because pid exists: #{@pid}"
        return false
      end

      @pid = run_command(command_to_warm_for(queue_server_url))
      return @pid
    end
    
    def run(queue_server_url, cucumber_options)
      if running?
        Testjour.logger.info "Not running because pid exists: #{@pid}"
        return false
      end
      
      # @pid = fork do
        system(command_to_run_for(queue_server_url, cucumber_options))
      # end
      # 
      # Process.detach(@pid)
      # return @pid
    end
    
  protected
  
    def command_to_run_for(master_server_uri, cucumber_options)
      "#{testjour_bin_path} slave:run #{master_server_uri} -- #{cucumber_options.join(' ')}".strip
    end
    
    def command_to_warm_for(master_server_uri)
      "#{testjour_bin_path} slave:warm #{master_server_uri}".strip
    end
    
    def testjour_bin_path
      File.expand_path(File.dirname(__FILE__) + "/../../bin/testjour")
    end
    
    def running?
      return false unless @pid
      Process::kill 0, @pid.to_s.to_i
      true
    rescue Errno::ESRCH, Errno::EPERM
      false
    end
    
  end
  
end