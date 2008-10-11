require "testjour/commands/base_command"

module Testjour
  module CLI
    
    class HelpCommand < BaseCommand
      def self.command
        "help"
      end
      
      def run
        puts @parser.usage
        exit 1
      end
    end

    Parser.register_command HelpCommand
  end
end

