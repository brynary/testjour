module Testjour
  module CLI
    
    class SlaveStart < BaseCommand
      class StopServer < Exception
      end
      
      def self.command
        "slave:start"
      end
      
      def run
        wd = File.expand_path(".")
        pid_file = File.expand_path("./testjour_slave.pid")

        verify_pid_doesnt_exist(pid_file)

        at_exit { remove_pid(pid_file) }
        trap("TERM") { Testjour.logger.info "TERM signal received."; raise StopServer.new }

        logfile = File.expand_path("./daemonizing.log")
        Daemonize.daemonize(logfile)

        # change back to the original starting directory
        Dir.chdir(wd)

        write_pid(pid_file)

        Testjour::Bonjour.serve(Testjour::SlaveServer.start)
        DRb.thread.join
        
      rescue StopServer
        exit 0
      end
      
      def verify_pid_doesnt_exist(pid_file)
        if File.exist?(pid_file)
          puts "!!! PID file #{pid_file} already exists.  testjour_slave could be running already."
          puts "!!! Exiting with error.  You must stop testjour_slave and clear the .pid before I'll attempt a start."
          exit 1
        end
      end
      
      def remove_pid(pid_file)
        File.unlink(pid_file) if pid_file and File.exists?(pid_file)
      end
      
      def write_pid(pid_file)
        open(pid_file,"w") {|f| f.write(Process.pid) }
        open(pid_file,"w") do |f|
          f.write(Process.pid)
          File.chmod(0644, pid_file)
        end
      end
      
    end
    
  end
end