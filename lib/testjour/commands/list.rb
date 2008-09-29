module Testjour
  module Commands
    
    class List < Testjour::Command
      
      def run
        available_servers = Testjour::Jour.list
        
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
    
  end
end

