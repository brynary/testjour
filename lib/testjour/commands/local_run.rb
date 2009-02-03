require "testjour/commands/command"
require "cucumber"
require "testjour/cucumber_extensions/http_formatter"

module Testjour
module Commands
    
  class LocalRun < Command
    
    def execute
      require 'cucumber/cli/main'
      
      cucumber_configuration.load_language
      step_mother.options = cucumber_configuration.options

      require_files
      work
    end
    
    def work
      HttpQueue.with_queue do |queue|
        feature_file = true
        
        while feature_file
          feature_file = queue.pop(:feature_files)
          
          if feature_file
            Testjour.logger.info "Running: #{feature_file}"
            features = load_plain_text_feature(feature_file)
            visit_features(features)
          end
        end
      end
    end
    
    def visit_features(features)
      visitor = Testjour::HttpFormatter.new(step_mother, StringIO.new, cucumber_configuration.options)
      visitor.visit_features(features)
    end
    
    def require_files
      cucumber_configuration.files_to_require.each do |lib|
        require lib
      end
    end
    
    def load_plain_text_feature(file)
      features = Cucumber::Ast::Features.new(cucumber_configuration.ast_filter)
      features.add_feature(parser.parse_file(file))
      return features
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