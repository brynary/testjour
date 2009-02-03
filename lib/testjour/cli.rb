module Testjour
  class CLI
    
    def self.execute(*args)
      new(*args).execute
    end
    
    def initialize(args, out_stream = STDOUT, error_stream = STDERR)
      if args.first == "--help"
        out_stream.puts "testjour help:"
      else
        out_stream.puts "testjour 0.3"
      end
    end
    
    def execute
      0
    end
    
  end
end