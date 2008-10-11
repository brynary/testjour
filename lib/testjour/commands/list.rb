require "testjour/commands/base_command"
require "testjour/bonjour"

module Testjour
  module CLI
    
    class List < BaseCommand
      def self.command
        "list"
      end
      
      def run
        available_servers = Testjour::Bonjour.list
        
        if available_servers.any?
          puts
          puts "Testjour servers:"
          puts 
          available_servers.each do |server|
            puts "    #{server.name} (#{server.host}:#{server.port})"
          end
        else
          puts
          puts "No testjour servers found."
        end
      end
      
    end
    
    Parser.register_command List
  end
end

