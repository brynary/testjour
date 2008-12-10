require "drb"
require "testjour/commands/base_command"
require "testjour/bonjour"

module Testjour
  module CLI
    
    class List < BaseCommand
      include Bonjour
      
      def self.command
        "list"
      end
      
      def initialize(*args)
        super
        Testjour.load_cucumber
        require "testjour/colorer"
      rescue LoadError
        # No cucumber, we can't use color :(
      end
      
      def run
        if bonjour_servers.any?
          puts
          puts "Testjour servers:"
          puts
          
          bonjour_servers.each do |server|
            puts server.status_line
          end
        else
          puts
          puts "No testjour servers found."
        end
      end
      
    end
    
  end
end

