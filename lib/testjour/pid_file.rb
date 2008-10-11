module Testjour
  
  class PidFile
    
    def initialize(path)
      @path = File.expand_path(path)
    end
    
    def verify_doesnt_exist
      if File.exist?(@path)
        puts "!!! PID file #{pid_file} already exists.  testjour could be running already."
        puts "!!! Exiting with error.  You must stop testjour and clear the .pid before I'll attempt a start."
        exit 1
      end
    end
    
    def send_signal(signal)
      pid = open(@path).read.to_i
      print "Sending #{signal} to Testjour at PID #{pid}..."
      begin
        Process.kill(signal, pid)
      rescue Errno::ESRCH
        puts "Process does not exist.  Not running."
      end

      puts "Done."
    end
    
    def write
      open(@path, "w") { |f| f.write(Process.pid) }
      open(@path, "w") do |f|
        f.write(Process.pid)
        File.chmod(0644, @path)
      end
    end
    
    def remove
      File.unlink(@path) if @path and File.exists?(@path)
    end
    
  end
  
end