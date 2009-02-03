require "testjour/commands"

module Testjour
  class CLI
    
    def self.execute(*args)
      new(*args).execute
    end
    
    def initialize(args, out_stream = STDOUT, err_stream = STDERR)
      @args = args
      @out_stream = out_stream
      @err_stream = err_stream
    end
    
    def command_class(args)
      if args.first == "--help"
        Commands::Help
      elsif args.first == "--version"
        Commands::Version
      elsif args.first == "run"
        Commands::Run
      elsif args.first == "local:run"
        Commands::LocalRun
      end
    end
    
    def execute
      klass = command_class(@args)
      klass.new(@args[1..-1], @out_stream, @err_stream).execute || 0
    end
    
  end
end