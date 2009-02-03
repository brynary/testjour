require "testjour/commands/command"
require "testjour/http_queue"
require "systemu"
require "net/http"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      testjour_path = File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
      cmd = "#{testjour_path} local:run #{@args.join(' ')}"

      pid = fork do
        exec File.expand_path(File.dirname(__FILE__) + "/../../../bin/httpq")
      end
      
      Process.detach(pid)
      at_exit do
        Process.kill("INT", pid)
      end
      
      HttpQueue.wait_for_service
      
      require 'cucumber/cli/main'
      configuration.load_language
      
      HttpQueue.with_net_http do |http|
        configuration.feature_files.each do |feature_file|
          post = Net::HTTP::Post.new("/")
          post.form_data = {"feature_file" => feature_file}
          http.request(post)
        end
      end
        
      status, stdout, stderr = systemu(cmd)
      
      @out_stream.write stdout
      @err_stream.write stderr
      status.exitstatus
    end
    
    def configuration
      return @configuration if @configuration
      
      @configuration = Cucumber::Cli::Configuration.new(StringIO.new, StringIO.new)
      @configuration.parse!(@args)
      @configuration
    end
    
  end
  
end
end