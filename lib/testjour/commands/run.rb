module Testjour
  module Commands
    
    class Run < Testjour::Command
      class << self
        attr_accessor :step_mother
      end
      
      def run
        require File.expand_path("./vendor/plugins/cucumber/lib/cucumber")
        require File.expand_path(File.dirname(__FILE__) + "/../../../lib/testjour")

        available_servers = Testjour::Jour.list
        
        if available_servers.any?
          Testjour::QueueServer.with_server do |queue|    
            Testjour::QueueingExecutor.queue = queue
        
            require "cucumber"
            
            Cucumber::CLI.class_eval do
              def require_files
                ARGV.clear # Shut up RSpec
                require "cucumber/treetop_parser/feature_en"
                require "cucumber/treetop_parser/feature_parser"
              end
            end
              
        
            Testjour.logger.debug "Queueing features..."
            
            ARGV.replace(@non_options)
            
            @executor = Testjour::QueueingExecutor.new(self.class.step_mother)
            Cucumber::CLI.executor = @executor
            Cucumber::CLI.execute
            Testjour.logger.debug "Done queueing features."
        
            found_server = 0
        
            available_servers.each do |server|
              slave_server = DRbObject.new(nil, server.uri)
              result = slave_server.run(DRb.uri, File.expand_path("."))
        
              if result
                Testjour.logger.info "Requesting buld from available server: #{server.uri}. Accepted."
                found_server += 1
              else
                Testjour.logger.info "Requesting buld from available server: #{server.uri}. Rejected."
              end
            end
        
            if found_server > 0
              puts
              puts "#{found_server} slave accepted the build request. Waiting for results."
              puts
        
              @executor.wait_for_results
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
      
    end
    
  end
end

Testjour::Commands::Run.step_mother = step_mother