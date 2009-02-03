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
      
      HttpQueue.with_net_http do |http|
        code = 200
        
        while code == 200
          get = Net::HTTP::Get.new("/feature_files")
          response  = http.request(get)
          code      = response.code.to_i
          
          if code == 200
            feature_file = response.body
            
            File.open("testjour.log", "w") do |log|
              log.puts feature_file
            end
            
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