require "testjour/commands/command"
require "testjour/http_queue"
require "testjour/cucumber_extensions/step_counter"

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
    
      @step_count = count_steps(cucumber_configuration.feature_files)
      @feature_files_count = cucumber_configuration.feature_files.size
      
      HttpQueue.with_queue do |queue|
        cucumber_configuration.feature_files.each do |feature_file|
          queue.push(:feature_files, feature_file)
        end
      end
    end
    
    def start_slaves
      testjour_path = File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
      cmd = "#{testjour_path} local:run #{@args.join(' ')}"
      
      local_slave_count.times do
        Testjour.logger.info "Starting slave: #{cmd}"
        
        pid = fork do
          silence_stream(STDOUT) do
            exec(cmd)
          end
        end
      
        Process.detach(pid)
      end
    end
    
    def print_results
      results = []
      
      HttpQueue.with_queue do |queue|
        @step_count.times do
          result = queue.pop(:results)
          
          @out_stream.print result
          @out_stream.flush
          
          results << result
        end
      end
      
      return results.include?("F") ? 1 : 0
    end
    
    def count_steps(feature_files)
      features = load_plain_text_features(feature_files)
      visitor = Testjour::StepCounter.new(step_mother)
      visitor.visit_features(features)
      return visitor.count
    end
    
    def load_plain_text_features(files)
      features = Cucumber::Ast::Features.new(cucumber_configuration.ast_filter)
      
      Array(files).each do |file|
        features.add_feature(parser.parse_file(file))
      end
      
      return features
    end
    
    def local_slave_count
      [@feature_files_count, max_local_slaves].min
    end
    
    def max_local_slaves
      2
    end
    
    def parser
      @parser ||= Cucumber::Parser::FeatureParser.new
    end
    
    def step_mother
      Cucumber::Cli::Main.instance_variable_get("@step_mother")
    end
    
  end
  
end
end