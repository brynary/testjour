require "uri"

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
      retryable :tries => 2, :on => RsyncFailed do
        Testjour.logger.info "Rsyncing: #{command}"
        copy
        Testjour.logger.debug("Rsync finished in %.2fs" % elapsed_time)
        raise RsyncFailed.new unless successful?
      end
    end
    
    def copy
      @start_time = Time.now
      @successful = system(command)
    end
    
    def elapsed_time
      Time.now - @start_time
    end
    
    def successful?
      @successful
    end
    
    def command
      "rsync -az --delete --exclude=.git --exclude=*.log --exclude=*.pid #{uri.user}@#{uri.host}:#{uri.path}/ #{destination_dir}"
    end
    
    def destination_dir
      File.expand_path(".")
    end
      
    def uri
      URI.parse(@source_uri)
    end
    
  end
end