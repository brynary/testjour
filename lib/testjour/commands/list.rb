module Testjour
  module Commands
    
    class List < Testjour::Command
      
      def run
        available_servers = Testjour::Jour.list
        
        available_servers.each do |server|
          puts
          puts server.name
          puts server.host
          puts server.port
        end
      end
      
    end
    
  end
end

