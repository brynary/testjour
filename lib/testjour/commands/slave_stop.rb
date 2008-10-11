module Testjour
  module CLI
    
    class SlaveStop < BaseCommand
      def self.command
        "slave:stop"
      end
      
      def run
        pid_file = File.expand_path("./testjour_slave.pid")
        send_signal("TERM", pid_file)
      end
      
      def send_signal(signal, pid_file)
        pid = open(pid_file).read.to_i
        print "Sending #{signal} to Testjour at PID #{pid}..."
        begin
          Process.kill(signal, pid)
        rescue Errno::ESRCH
          puts "Process does not exist.  Not running."
        end

        puts "Done."
      end
      
    end
    
  end
end