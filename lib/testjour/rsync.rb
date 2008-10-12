require "uri"

module Testjour
  
  class Rsync
    
    def self.sync(source_uri)
      destination_dir = File.expand_path(".")
      uri = URI.parse(source_uri)
      
      command = "rsync -az --delete --exclude=.git --exclude=*.log #{uri.host}:#{uri.path}/ #{destination_dir}"
      
      Testjour.logger.info "Rsyncing: #{command}"
      start_time = Time.now
      successful = system command
      
      if successful
        time = Time.now - start_time
        Testjour.logger.debug("Rsync finished in %.2f" % time)
      else
        raise "RSync Failed!!"
      end
    end
    
  end
end