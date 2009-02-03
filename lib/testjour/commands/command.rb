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
      @cucumber_configuration.parse!(@args)
      @cucumber_configuration
    end
    
  end
  
end
end