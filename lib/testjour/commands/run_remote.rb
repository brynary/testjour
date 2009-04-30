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
    
    def execute
      configuration.parse!
      configuration.parse_uri!
      
      Dir.chdir(configuration.in) do
        Testjour.setup_logger(configuration.in)
        Testjour.logger.info "Starting run:remote"

        rsync

        begin
          Testjour.logger.info "Setup"
          configuration.setup
          configuration.setup_mysql
          Testjour.logger.info "Requiring"
          require_files
          Testjour.logger.info "Working"

          work
        rescue Object => ex
          Testjour.logger.error "run:remote error: #{ex.message}"
          Testjour.logger.error ex.backtrace.join("\n")
        end
      end
    end
    
    def rsync
      Rsync.copy_to_current_directory_from(configuration.rsync_uri)
    end
    
  end
  
end
end