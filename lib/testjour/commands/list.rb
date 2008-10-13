require "drb"
require "testjour/commands/base_command"
require "testjour/bonjour"

module Testjour
  module CLI
    
    class List < BaseCommand
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
        available_servers = Testjour::Bonjour.list
        
        if available_servers.any?
          puts
          puts "Testjour servers:"
          puts
          
          available_servers.each do |server|
            slave_server = DRbObject.new(nil, server.uri)
            status = colorize_status(slave_server.status)
            puts "    %-12s %s %s" % [server.name, status, "#{server.host}:#{server.port}"]
          end
        else
          puts
          puts "No testjour servers found."
        end
      end
      
      def colorize_status(status)
        formatted_status = ("%-12s" % status)
        return formatted_status unless defined?(Testjour::Colorer)
        
        case formatted_status.strip
        when "available"
          Testjour::Colorer.green(formatted_status)
        else
          Testjour::Colorer.yellow(formatted_status)
        end
      end
      
    end
    
    Parser.register_command List
  end
end

