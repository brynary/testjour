require "drb"

require "testjour/commands/base_command"
require "testjour/queue_server"
require "testjour/bonjour"

module Testjour
  module CLI
    
    class Run < BaseCommand
      def self.command
        "run"
      end
      
      def initialize(*args)
        Testjour.logger.debug "Runner command #{self.class}..."
        Testjour.load_cucumber
        
        super
        @found_server = 0
        require "testjour/cucumber_extensions/queueing_executor"
        require "testjour/colorer"
      end
      
      def run
        if available_servers.any?
          Testjour::QueueServer.with_server do |queue|
            disable_cucumber_require
            queue_features(queue)
        
            available_servers.each do |server|
              request_build_from(server)
            end
        
            print_results
          end
        else
          puts
          puts Testjour::Colorer.failed("Don't see any available test servers. Try again later.")
        end
      end
      
      def disable_cucumber_require
        Cucumber::CLI.class_eval do
          def require_files
            ARGV.clear # Shut up RSpec
          end
        end
      end
      
      def queue_features(queue)
        Testjour.logger.debug "Queueing features..."
        
        ARGV.replace(@non_options)
        Cucumber::CLI.executor = Testjour::QueueingExecutor.new(queue, Cucumber::CLI.step_mother)
        Cucumber::CLI.execute
      end
      
      def print_results
        if @found_server > 0
          puts
          puts "#{@found_server} slave accepted the build request. Waiting for results."
          puts
    
          Cucumber::CLI.executor.wait_for_results
          Testjour.logger.debug "DONE"
        else
          puts
          puts Testjour::Colorer.failed("Found available servers, but none accepted the build request. Try again later.")
        end
      end
      
      def available_servers
        @available_servers ||= Testjour::Bonjour.list
      end
      
      def request_build_from(server)
        slave_server = DRbObject.new(nil, server.uri)
        result = slave_server.run(testjour_uri, File.expand_path("."))
  
        if result
          Testjour.logger.info "Requesting buld from available server: #{server.uri}. Accepted."
          @found_server += 1
        else
          Testjour.logger.info "Requesting buld from available server: #{server.uri}. Rejected."
        end
      end
      
      def testjour_uri
        DRb.uri.gsub(/^druby:/, "testjour:")
      end
    end
   
    Parser.register_command Run
  end
end