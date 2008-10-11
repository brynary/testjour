require "drb"

require "testjour/commands/base_command"
require "daemons/daemonize"
require "testjour/pid_file"
require "testjour/slave_server"
require "testjour/bonjour"

module Testjour
  module CLI
    
    class SlaveStart < BaseCommand
      class StopServer < Exception
      end
      
      def self.command
        "slave:start"
      end
      
      def run
        original_working_directory = File.expand_path(".")
        
        pid_file = PidFile.new("./testjour_slave.pid")
        pid_file.verify_doesnt_exist
        at_exit { pid_file.remove }
        register_signal_handler

        logfile = File.expand_path("./daemonizing.log")
        Daemonize.daemonize(logfile)

        Dir.chdir(original_working_directory)
        pid_file.write

        Testjour::Bonjour.serve(Testjour::SlaveServer.start)
        DRb.thread.join
      rescue StopServer
        exit 0
      end
      
      def register_signal_handler
        trap("TERM") do
          Testjour.logger.info "TERM signal received."
          raise StopServer.new
        end
      end
      
    end
    
    Parser.register_command SlaveStart
  end
end