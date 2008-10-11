require "testjour/commands/base_command"

module Testjour
  module CLI

    class VersionCommand < BaseCommand
      def self.command
        "version"
      end
  
      def run
        puts "Testjour #{Testjour::VERSION}"
      end
    end
    
    Parser.register_command VersionCommand
  end
end