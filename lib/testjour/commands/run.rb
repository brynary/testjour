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

      HttpQueue.with_queue do
        require 'cucumber/cli/main'
        configuration.load_language
      
        HttpQueue.with_net_http do |http|
          configuration.feature_files.each do |feature_file|
            post = Net::HTTP::Post.new("/feature_files")
            post.form_data = {"data" => feature_file}
            http.request(post)
          end
        end
        
        status, stdout, stderr = systemu(cmd)
      
        @out_stream.write stdout
        @err_stream.write stderr
        status.exitstatus
      end
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