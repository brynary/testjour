require "testjour/commands/command"

module Testjour
module Commands
    
  class Run < Command
    
    def execute
      result = nil
      
      File.open("testjour.log", "w") do |log|
        log.puts @args.first
      end

      require 'cucumber/cli/main'
      step_mother = Cucumber::Cli::Main.instance_variable_get("@step_mother")
      
      begin
        Cucumber::Cli::Main.new(@args, StringIO.new, StringIO.new).execute!(step_mother)
      rescue SystemExit => ex
        result = ex.success?
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