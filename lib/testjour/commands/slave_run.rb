require "testjour/commands/local_run"
require "testjour/rsync"

module Testjour
  module CLI
  
    class SlaveRun < LocalRun
      def self.command
        "slave:run"
      end
  
      def run
        Testjour::Rsync.copy_to_current_directory_from(@queue)
        super
      end
    end

  end
end
