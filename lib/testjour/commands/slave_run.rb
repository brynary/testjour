module Testjour
  module Commands
  
    class SlaveRun < Testjour::Command
      
      def initialize(non_options, options)
        @chdir = File.expand_path(options[:chdir] || ".")
        @queue = options[:queue]
      
        require File.expand_path(@chdir + "/vendor/plugins/cucumber/lib/cucumber")
        require File.expand_path(File.dirname(__FILE__) + "/../../testjour")
      
        # Object.class_eval do
        #   include Cucumber::StepMethods
        #   include Cucumber::Tree
        # end
      
        Cucumber.load_language("en")

        require "cucumber/treetop_parser/feature_en"
        require "cucumber/treetop_parser/feature_parser"
      end
  
      def run
        ARGV.clear # Don't pass along args to RSpec
        
        Testjour.logger.debug "Runner starting..."
        
        ENV["RAILS_ENV"] = "test"
        require File.expand_path(@chdir + '/config/environment')

        # Testjour::Rsync.sync(@queue, @chdir, File.expand_path("~/temp3"))

        Testjour::MysqlDatabaseSetup.with_new_database do
          DRb.start_service
          
          queue_server = DRbObject.new(nil, @queue)
          Testjour.executor.formatter = Testjour::DRbFormatter.new(queue_server)
          
          require_steps(File.expand_path(@chdir + "/features/steps/*.rb"))

          begin
            loop do
              begin
                run_file(queue_server.take_work)
              rescue Testjour::QueueServer::NoWorkUnitsAvailableError
                # If no work, ignore and keep looping
              end
            end
          rescue DRb::DRbConnError
            Testjour.logger.debug "DRb connection error. Exiting runner."
          end

        end
      end
    
      def require_steps(pattern)
        Dir[File.expand_path(pattern)].each do |file|
          Testjour.logger.debug "Requiring step file: #{file}"
          require file
        end
      end
  
      def run_file(file)
        Testjour.logger.debug "Running feature file: #{file}"
        features = parser.parse_feature(File.expand_path(file))
        Testjour.executor.visit_features(features)
      end
  
      def parser
        @parser ||= Cucumber::TreetopParser::FeatureParser.new
      end
  
    end

  end
end
