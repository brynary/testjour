module Testjour
  
  class Rsync
    
    def self.sync(source_host, source_dir, destination_dir)
      # TODO - Remove blatant hackery
      source_host =~ /^druby:\/\/(.+)\.:[0-9]+$/
      source_host = $1
      
      command = "rsync -az --delete --exclude=.git --exclude=*.log #{source_host}:#{source_dir}/ #{destination_dir}"
      
      Testjour.logger.info "Rsyncing: #{command}"
      successful = system command
      raise "RSync Failed!!" unless successful
    end
    
  end
end