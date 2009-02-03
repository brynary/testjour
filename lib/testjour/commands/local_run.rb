require "testjour/commands/command"

module Testjour
module Commands
    
  class LocalRun < Command
    
    def execute
      File.open("testjour.log", "w") do |log|
        log.puts @args.first
      end
      
      require 'cucumber/cli/main'
      
      configuration.load_language
      step_mother.options = configuration.options

      feature_files = []
      
      HttpQueue.with_net_http do |http|
        configuration.feature_files.each do |feature_file|
          get = Net::HTTP::Get.new("/feature_files")
          response = http.request(get)
          feature_files << response.body
        end
      end
      
      features = load_plain_text_features(feature_files)
      
      require_files
      visit_features(features)
      
      if failed?(features)
        @out_stream.puts "Failed"
        1
      else
        @out_stream.puts "Passed"
        0
      end
    end
    
    def visit_features(features)
      visitor = configuration.build_formatter_broadcaster(step_mother)
      visitor.visit_features(features)
    end
    
    def configuration
      return @configuration if @configuration
      
      @configuration = Cucumber::Cli::Configuration.new(StringIO.new, StringIO.new)
      @configuration.parse!(@args)
      @configuration
    end
    
    def require_files
      configuration.files_to_require.each do |lib|
        require lib
      end
    end
    
    def load_plain_text_features(files)
      features = Cucumber::Ast::Features.new(configuration.ast_filter)
      parser = Cucumber::Parser::FeatureParser.new

      files.each do |f|
        features.add_feature(parser.parse_file(f))
      end
      
      return features
    end
    
    def failed?(features)
      features.steps[:failed].any? ||
      (configuration.strict? && features.steps[:undefined].length)
    end
    
    def step_mother
      Cucumber::Cli::Main.instance_variable_get("@step_mother")
    end
    
  end
  
end
end