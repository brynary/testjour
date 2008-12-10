require "testjour/commands/base_command"
require "testjour/pid_file"

module Testjour
  module CLI
    
    class SlaveStop < BaseCommand
      def self.command
        "slave:stop"
      end
      
      def initialize(*args)
        Testjour.logger.debug "Runner command #{self.class}..."
        super
      end
      
      def run
        PidFile.term("./testjour_slave.pid")
      end
    end
    
  end
end