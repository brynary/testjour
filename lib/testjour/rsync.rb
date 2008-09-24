module Testjour
  
  class Rsync
    
    def self.sync(source_host, source_dir, destination_dir)
      command = "rsync -az --delete --exclude=.git --exclude=*.log #{source_host}:#{source_dir}/ #{destination_dir}"
      successful = system command
      raise "RSync Failed!!" unless successful
    end
    
  end
end