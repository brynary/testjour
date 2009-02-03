require "testjour/commands/command"
require "testjour/http_queue"
require "net/http"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
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
        
        testjour_path = File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
        cmd = "#{testjour_path} local:run #{@args.join(' ')}"
        
        pid = fork do
          silence_stream(STDOUT) do
            exec(cmd)
          end
        end
        Process.waitpid(pid)
        
        results = []
        
        HttpQueue.with_net_http do |http|
          configuration.feature_files.each do |feature_file|
            get = Net::HTTP::Get.new("/results")
            results << http.request(get).body
          end
        end
        
        if results.include?("F")
          @out_stream.write "Failed"
          1
        else
          @out_stream.write "Passed"
          0
        end
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