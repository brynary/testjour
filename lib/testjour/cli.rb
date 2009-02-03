require "testjour/commands"

module Testjour
  class CLI
    
    def self.execute(*args)
      new(*args).execute
    end
    
    def initialize(args, out_stream = STDOUT, err_stream = STDERR)
      klass = command_class(args)
      klass.new(out_stream, err_stream).execute
    end
    
    def command_class(args)
      if args.first == "--help"
        Commands::Help
      else
        Commands::Version
      end
    end
    
    def execute
      0
    end
    
  end
end