require "uri"
require "systemu"

module Testjour
  
  class RsyncFailed < StandardError
  end
  
  class Rsync
    
    def self.copy_to_current_directory_from(source_uri)
      new(source_uri).copy_with_retry
    end
    
    def initialize(source_uri)
      @source_uri = source_uri
    end

    def copy_with_retry
      # retryable :tries => 2, :on => RsyncFailed do
        Testjour.logger.info "Rsyncing: #{command}"
        copy
        
        if successful?
          Testjour.logger.debug("Rsync finished in %.2fs" % elapsed_time)
        else
          Testjour.logger.debug("Rsync failed in %.2fs" % elapsed_time)
          Testjour.logger.debug("Rsync stdout: #{@stdout}")
          Testjour.logger.debug("Rsync stderr: #{@stderr}")
          raise RsyncFailed.new 
        end
      # end
    end
    
    def copy
      @start_time = Time.now
      
      status, @stdout, @stderr = systemu(command)
      @exit_code = status.exitstatus
    end
    
    def elapsed_time
      Time.now - @start_time
    end
    
    def successful?
      @exit_code.zero?
    end
    
    def command
      "rsync -az --delete --exclude=.git --exclude=*.log --exclude=*.pid #{@source_uri}/ #{destination_dir}"
    end
    
    def destination_dir
      File.expand_path(".")
    end
    
  end
end