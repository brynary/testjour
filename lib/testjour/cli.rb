require "testjour/commands"

module Testjour
  class CLI
    
    def self.execute(*args)
      new(*args).execute
    end
    
    def initialize(args, out_stream = STDOUT, err_stream = STDERR)
      if args.first == "--help"
        Help.new(out_stream, err_stream).execute
      else
        Version.new(out_stream, err_stream).execute
      end
    end
    
    def execute
      0
    end
    
  end
end