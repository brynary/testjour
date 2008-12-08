require "uri"

module Testjour
  
  class RsyncFailed < StandardError
  end
  
  class Rsync
    
    def self.copy_to_current_directory_from(source_uri)
      destination_dir = File.expand_path(".")
      uri = URI.parse(source_uri)
      
      command = "rsync -az --delete --exclude=.git --exclude=*.log --exclude=*.pid #{uri.user}@#{uri.host}:#{uri.path}/ #{destination_dir}"
      
      Testjour.logger.info "Rsyncing: #{command}"
      start_time = Time.now
      successful = system command
      
      if successful
        time = Time.now - start_time
        Testjour.logger.debug("Rsync finished in %.2fs" % time)
      else
        raise RsyncFailed.new
      end
    end
    
  end
end