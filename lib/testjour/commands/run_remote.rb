require "testjour/commands/command"
require "cucumber"
require "uri"
require "daemons/daemonize"
require "testjour/cucumber_extensions/http_formatter"
require "testjour/mysql"
require "testjour/rsync"
require "stringio"

module Testjour
module Commands
    
  class RunRemote < RunSlave
        
    def dir
      configuration.in
    end
    
    def before_require
      rsync
      super
    end
        
    def rsync
      Rsync.copy_to_current_directory_from(configuration.rsync_uri)
    end
    
  end
  
end
end