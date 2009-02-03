require "testjour/commands/command"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      File.open("testjour.log", "w") do |log|
        log.puts @args.first
      end
      
      require 'cucumber/cli/main'
      step_mother = Cucumber::Cli::Main.instance_variable_get("@step_mother")
      
      configuration = Cucumber::Cli::Configuration.new(StringIO.new, StringIO.new)
      configuration.parse!(@args)
      configuration.load_language
      step_mother.options = configuration.options

      configuration.files_to_require.each do |lib|
        require lib
      end
    
      features = Cucumber::Ast::Features.new(configuration.ast_filter)
      parser = Cucumber::Parser::FeatureParser.new

      configuration.feature_files.each do |f|
        features.add_feature(parser.parse_file(f))
      end

      visitor = configuration.build_formatter_broadcaster(step_mother)
      visitor.visit_features(features)
    
      failure = features.steps[:failed].any? || (configuration.strict? && features.steps[:undefined].length)
      
      if failure
        @out_stream.puts "Failed"
        1
      else
        @out_stream.puts "Passed"
        0
      end
    end
    
  end
  
end
end