require "drb"

require "testjour/commands/base_command"
require "testjour/queue_server"
require "testjour/cucumber_extensions/drb_formatter"
require "testjour/mysql"

module Testjour
  module CLI
  
    class SlaveRun < BaseCommand
      def self.command
        "slave:run"
      end
      
      def option_parser
        OptionParser.new do |opts|
          opts.on("-c", "--chdir", "=PATH", "Change to dir before starting (will be expanded).") do |value|
            @options[:chdir] = value
          end
          
          opts.on("-q", "--queue", "=DRB_URI", "Where to grab the work") do |value|
            @options[:queue] = value
          end
        end
      end
      
      def initialize(parser, args)
        super
        @chdir = File.expand_path(@options[:chdir] || ".")
        @queue = @options[:queue]
      end
  
      def run
        ARGV.clear # Don't pass along args to RSpec
        Testjour.logger.debug "Runner starting..."
        
        ENV["RAILS_ENV"] = "test"
        require File.expand_path(@chdir + '/config/environment')

        # Testjour::Rsync.sync(@queue, @chdir, File.expand_path("~/temp3"))

        Testjour::MysqlDatabaseSetup.with_new_database do
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
            Testjour.logger.debug "DRb connection error. (This is normal.) Exiting runner."
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
        features = feature_parser.parse_feature(File.expand_path(file))
        Testjour.executor.visit_features(features)
      end
      
      def queue_server
        @queue_server ||= begin
          DRb.start_service
          DRbObject.new(nil, @queue)
        end
      end
  
      def feature_parser
        @feature_parser ||= Cucumber::TreetopParser::FeatureParser.new
      end
  
    end

    Parser.register_command SlaveRun
  end
end
