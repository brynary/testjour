module Testjour
module Commands

  class Command
    
    def initialize(args = [], out_stream = STDOUT, err_stream = STDERR)
      @args = args
      @out_stream = out_stream
      @err_stream = err_stream
    end
    
  protected
  
    def cucumber_configuration
      return @cucumber_configuration if @cucumber_configuration
      
      @cucumber_configuration = Cucumber::Cli::Configuration.new(StringIO.new, StringIO.new)
      Testjour.logger.info "Arguments for Cucumber: #{@args.inspect}"
      @cucumber_configuration.parse!(@args.dup)
      @cucumber_configuration
    end
    
    def load_plain_text_features(files)
      features = Cucumber::Ast::Features.new(cucumber_configuration.ast_filter)
      
      Array(files).each do |file|
        features.add_feature(parser.parse_file(file))
      end
      
      return features
    end
    
    def parser
      @parser ||= Cucumber::Parser::FeatureParser.new
    end
    
    def step_mother
      Cucumber::Cli::Main.instance_variable_get("@step_mother")
    end
    
    def testjour_path
      File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
    end
    
  end
  
end
end