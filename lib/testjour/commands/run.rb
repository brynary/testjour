require "testjour/commands/command"
require "testjour/http_queue"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      HttpQueue.with_queue_server do
        queue_features
        start_slaves
        print_results
      end
    end
    
    def queue_features
      require 'cucumber/cli/main'
      cucumber_configuration.load_language
    
      HttpQueue.with_queue do |queue|
        cucumber_configuration.feature_files.each do |feature_file|
          queue.push(:feature_files, feature_file)
        end
      end
    end
    
    def start_slaves
      testjour_path = File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
      cmd = "#{testjour_path} local:run #{@args.join(' ')}"
      
      pid = fork do
        silence_stream(STDOUT) do
          exec(cmd)
        end
      end
      
      Process.waitpid(pid)
    end
    
    def print_results
      results = []
      
      HttpQueue.with_queue do |queue|
        cucumber_configuration.feature_files.each do |feature_file|
          results << queue.pop(:results)
        end
      end
      
      results.compact!
      
      results.each do |result|
        @out_stream.print result
        @out_stream.flush
      end
      
      if results.include?("F")
        1
      else
        0
      end
    end
    
  end
  
end
end