require "testjour/commands/command"
require "cucumber"
require "uri"
require "daemons/daemonize"
require "testjour/cucumber_extensions/http_formatter"
require "testjour/mysql"
require "stringio"

module Testjour
module Commands
    
  class RunSlave < Command
    
    def execute
      configuration.parse!
      configuration.parse_uri!
      
      Dir.chdir(configuration.path) do
        Testjour.setup_logger(configuration.path)
        Testjour.logger.info "Starting run:slave"
        
        configuration.setup
        require_files
        work
      end
    end

    def work
      HttpQueue.with_queue(configuration.queue_uri) do |queue|
        feature_file = true
        
        while feature_file
          begin
            feature_file = queue.pop(:feature_files)
          rescue Curl::Err::ConnectionFailedError
            feature_file = false
          end
          
          if feature_file
            Testjour.logger.info "Running: #{feature_file}"
            features = load_plain_text_features(feature_file)
            execute_features(features)
          end
        end
      end
    end
    
    def execute_features(features)
      visitor = Testjour::HttpFormatter.new(step_mother, StringIO.new, configuration.queue_uri)
      visitor.visit_features(features)
    end
    
    def require_files
      configuration.files_to_require.each do |lib|
        Testjour.logger.info "Requiring: #{lib}"
        require lib
      end
    end
    
    def schema_load_command(database_name)
      "#{testjour_path} mysql:load_schema #{database_name}"
    end
    
  end
  
end
end