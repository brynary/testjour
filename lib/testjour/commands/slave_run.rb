require "drb"
require "uri"

require "testjour/commands/base_command"
require "testjour/rsync"
require "testjour/queue_server"
require "testjour/cucumber_extensions/drb_formatter"
require "testjour/mysql"

module Testjour
  module CLI
  
    class SlaveRun < BaseCommand
      def self.command
        "slave:run"
      end
      
      def initialize(parser, args)
        Testjour.logger.debug "Runner command #{self.class}..."
        super
        @queue = @non_options.first
      end
  
      def run
        Testjour::Rsync.copy_to_current_directory_from(@queue)
        
        ARGV.clear # Don't pass along args to RSpec
        Testjour.load_cucumber
        
        Testjour::MysqlDatabaseSetup.with_new_database do
          Cucumber::CLI.executor.formatters = Testjour::DRbFormatter.new(queue_server)
          require_files

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
      
      def require_files
        cli = Cucumber::CLI.new
        cli.parse_options!(@non_options)
        cli.send(:require_files)
      end
  
      def run_file(file)
        Testjour.logger.debug "Running feature file: #{file}"
        features = feature_parser.parse_feature(File.expand_path(file))
        Cucumber::CLI.executor.visit_features(features)
      end
      
      def queue_server
        @queue_server ||= begin
          DRb.start_service
          DRbObject.new(nil, drb_uri)
        end
      end
      
      def drb_uri
        uri = URI.parse(@queue)
        uri.scheme = "druby"
        uri.path = ""
        uri.user = nil
        uri.to_s
      end
  
      def feature_parser
        @feature_parser ||= Cucumber::TreetopParser::FeatureParser.new
      end
  
    end

  end
end
