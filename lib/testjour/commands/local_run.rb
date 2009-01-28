require "drb"
require "uri"
require "systemu"

require "testjour/commands/base_command"
require "testjour/queue_server"
require "testjour/cucumber_extensions/drb_formatter"

module Testjour
  module CLI
  
    class LocalRun < BaseCommand
      
      def self.command
        "local:run"
      end
      
      def initialize(parser, args)
        Testjour.logger.debug "Runner command #{self.class}..."
        super
        @queue = @non_options.shift
      end
  
      def run
        ARGV.clear # Don't pass along args to RSpec
        Testjour.load_cucumber
        
        status, stdout, stderr = systemu("#{testjour_bin_path} mysql:create")
        database_name = stdout.split.last.strip
        Testjour.logger.info "MySQL db name: #{database_name.inspect}"
        
        Cucumber::CLI.executor.formatters = Testjour::DRbFormatter.new(queue_server)
        require_files
        work
        
        status, stdout, stderr = systemu("#{testjour_bin_path} mysql:drop #{database_name}")
        Testjour.logger.info "Dropped MySQL db: #{status.inspect}, #{stdout.inspect}, #{stderr.inspect}"
      end
      
      def work
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
      
      def require_files
        cli = Cucumber::CLI.new
        Testjour.logger.debug "Cucumber options: #{options_for_cucumber.inspect}"
        cli.parse_options!(options_for_cucumber)
        cli.send(:require_files)
      end
  
      def options_for_cucumber
        @non_options
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
