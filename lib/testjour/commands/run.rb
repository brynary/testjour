require "testjour/commands/command"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      result = nil
      
      File.open("testjour.log", "w") do |log|
        log.puts @args.first
      end
      
      silence_stream(STDOUT) do
        result = system "cucumber #{@args.first}"
      end
      
      if result
        @out_stream.puts "Passed"
        0
      else
        @out_stream.puts "Failed"
        1
      end
    end
    
  end
  
end
end