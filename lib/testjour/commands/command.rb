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
    
    def option_parser
      OptionParser.new do |opts|
        opts.on("--create-mysql-db", "Create MySQL for each slave") do |server|
          @options[:create_mysql_db] = true
        end
      end
    end
    
    def cucumber_configuration
      return @cucumber_configuration if @cucumber_configuration
      
      @cucumber_configuration = Cucumber::Cli::Configuration.new(StringIO.new, StringIO.new)
      
      cuc_args = @unknown_args + @args
      # cuc_args.delete("--create-mysql-db")
      Testjour.logger.info "Arguments for Cucumber: #{cuc_args.inspect}"
      
      @cucumber_configuration.parse!(cuc_args)
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