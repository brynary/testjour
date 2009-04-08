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
        @args_for_command = @args[1..-1]
        Commands::Help
      elsif args.first == "--version"
        @args_for_command = @args[1..-1]
        Commands::Version
      elsif args.first == "run:slave"
        @args_for_command = @args[1..-1]
        Commands::RunSlave
      elsif args.first == "run:remote"
        @args_for_command = @args[1..-1]
        Commands::RunRemote
      else
        @args_for_command = @args.dup
        Commands::Run
      end
    end
    
    def execute
      klass = command_class(@args)
      klass.new(@args_for_command, @out_stream, @err_stream).execute || 0
    end
    
  end
end