module Testjour
module Commands

  class Command
    
    def initialize(args = [], out_stream = STDOUT, err_stream = STDERR)
      @options = {}
      @args = args
      @out_stream = out_stream
      @err_stream = err_stream
    end
    
  protected
    
    def configuration
      return @configuration if @configuration
      @configuration = Configuration.new(@args)
      @configuration
    end
    
    def load_plain_text_features(files)
      features = Cucumber::Ast::Features.new
      
      Array(files).each do |file|
        features.add_feature(parser.parse_file(file, configuration.cucumber_configuration.options))
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