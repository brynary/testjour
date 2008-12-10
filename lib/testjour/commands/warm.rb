require "drb"

require "testjour/commands/base_command"
require "testjour/bonjour"

module Testjour
  module CLI
    
    class Warm < BaseCommand
      def self.command
        "warm"
      end
      
      def initialize(*args)
        Testjour.logger.debug "Runner command #{self.class}..."
        
        super
        @found_server = 0
        require "testjour/colorer"
      end
      
      def run
        if available_servers.any?
          available_servers.each do |server|
            request_warm_from(server)
          end
          
          print_results
        else
          puts
          puts Testjour::Colorer.failed("Don't see any available test servers. Try again later.")
        end
      end
      
      def available_servers
        @available_servers ||= Testjour::Bonjour.list
      end
      
      def request_warm_from(server)
        slave_server = DRbObject.new(nil, server.uri)
        result = slave_server.warm(testjour_uri)
  
        if result
          Testjour.logger.info "Requesting warm from available server: #{server.uri}. Accepted."
          @found_server += 1
        else
          Testjour.logger.info "Requesting warm from available server: #{server.uri}. Rejected."
        end
      end
      
      def print_results
        if @found_server > 0
          puts
          puts "#{@found_server} slave accepted the warm request."
        else
          puts
          puts Testjour::Colorer.failed("Found available servers, but none accepted the warm request. Try again later.")
        end
      end
      
      def testjour_uri
        DRb.start_service
        uri = URI.parse(DRb.uri)
        uri.path = File.expand_path(".")
        uri.scheme = "testjour"
        uri.user = `whoami`.strip
        uri.to_s
      end
    end
   
  end
end