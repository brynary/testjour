require "testjour/commands/command"
require "testjour/http_queue"
require "net/http"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      HttpQueue.with_queue_server do
        require 'cucumber/cli/main'
        cucumber_configuration.load_language
      
        HttpQueue.with_queue do |queue|
          cucumber_configuration.feature_files.each do |feature_file|
            queue.push(:feature_files, feature_file)
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
        
        HttpQueue.with_queue do |queue|
          cucumber_configuration.feature_files.each do |feature_file|
            results << queue.pop(:results)
          end
        end
        
        results.compact!
        
        if results.include?("F")
          @out_stream.write "Failed"
          1
        else
          @out_stream.write "Passed"
          0
        end
      end
    end
    
  end
  
end
end