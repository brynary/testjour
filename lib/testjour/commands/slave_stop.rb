module Testjour
  module CLI
    
    class SlaveStop < BaseCommand
      def self.command
        "slave:stop"
      end
      
      def run
        pid_file = PidFile.new("./testjour_slave.pid")
        pid_file.send_signal("TERM")
      end
      
    end
    
  end
end