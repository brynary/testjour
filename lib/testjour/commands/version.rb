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
    
  end
end