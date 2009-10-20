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

    def command_class
      case @args.first
      when "--help"
        @args.shift
        Commands::Help
      when "--version"
        @args.shift
        Commands::Version
      when "run:slave"
        @args.shift
        Commands::RunSlave
      when "run:remote"
        @args.shift
        Commands::RunRemote
      else
        Commands::Run
      end
    end

    def execute
      command_class.new(@args, @out_stream, @err_stream).execute || 0
    end

  end
end