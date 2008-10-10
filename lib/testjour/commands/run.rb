module Testjour
  module Commands
    
    class Run < Testjour::Command
      
      def run
        if available_servers.any?
          Testjour::QueueServer.with_server do |queue|
            
            Cucumber::CLI.class_eval do
              def require_files
                ARGV.clear # Shut up RSpec
                require "cucumber/treetop_parser/feature_en"
              end
            end
        
            Testjour.logger.debug "Queueing features..."
            
            ARGV.replace(@non_options)
            
            executor = Testjour::QueueingExecutor.new(queue, Testjour.step_mother)
            Cucumber::CLI.executor = executor
            Cucumber::CLI.execute
            
            Testjour.logger.debug "Done queueing features."
        
            @found_server = 0
        
            available_servers.each do |server|
              request_build_from(server)
            end
        
            if @found_server > 0
              puts
              puts "#{@found_server} slave accepted the build request. Waiting for results."
              puts
        
              executor.wait_for_results
              Testjour.logger.debug "DONE"
            else
              puts
              puts Testjour::Colorer.failed("Found available servers, but none accepted the build request. Try again later.")
            end
          end
        else
          puts
          puts Testjour::Colorer.failed("Don't see any available test servers. Try again later.")
        end
      end
      
      def available_servers
        @available_servers ||= Testjour::Jour.list
      end
      
      def request_build_from(server)
        slave_server = DRbObject.new(nil, server.uri)
        result = slave_server.run(DRb.uri, File.expand_path("."))
  
        if result
          Testjour.logger.info "Requesting buld from available server: #{server.uri}. Accepted."
          @found_server += 1
        else
          Testjour.logger.info "Requesting buld from available server: #{server.uri}. Rejected."
        end
      end
      
    end
    
  end
end