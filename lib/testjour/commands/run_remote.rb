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
        fork_additional_slaves
        super
      end
      
      def fork_additional_slaves
        @additional_slaves_launched = 0
        while (launch_additional_slave?) do
          if @child = fork
            Testjour.logger.info "Forked #{@child} as an additional slave"
            @additional_slaves_launched += 1
            Process.detach
          else
            @forked_slave = true
          end
        end
      end
    
      def launch_additional_slave?
        return false if @forked_slave
        configuration.max_remote_slaves > (1 + @additional_slaves_launched)
      end
      
      def number_of_additional_slaves
        configuration.max_remote_slaves - 1
      end
        
      def rsync
        Rsync.copy_to_current_directory_from(configuration.rsync_uri)
      end
    
    end
  
  end
end