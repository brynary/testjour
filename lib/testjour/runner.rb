#!/usr/bin/env ruby

require File.expand_path("./vendor/plugins/cucumber/lib/cucumber")
require File.expand_path(File.dirname(__FILE__) + "/../testjour")

Testjour.logger.info "Starting runner..."

Cucumber.disable_run

module Testjour
  
  class CucumberCli
  
    def initialize(queue_server, step_mother)
      @queue_server = queue_server
      
      Object.class_eval do
        extend Cucumber::StepMethods
        extend Cucumber::Tree
      end
      
      Cucumber.load_language("en")
      $executor = Cucumber::Executor.new(Testjour::DRbFormatter.new(queue_server), step_mother)

      require "cucumber/treetop_parser/feature_en"
      require "cucumber/treetop_parser/feature_parser"
    end
  
    def require_steps(pattern)
      Dir[File.expand_path(pattern)].each do |file|
        require file
      end
    end
  
    def run_file(file)
      features = parser.parse_feature(File.expand_path(file))
      $executor.visit_features(features)
    end
  
    def parser
      @parser ||= Cucumber::TreetopParser::FeatureParser.new
    end
  
  end
  
end

ENV["RAILS_ENV"] = "test"
require File.expand_path('./config/environment')

drb_uri = ARGV.shift
project_path = ARGV.shift

# Testjour::Rsync.sync(drb_uri, project_path, File.expand_path("~/temp3"))

Testjour::MysqlDatabaseSetup.with_new_database do
  DRb.start_service
  queue_server = DRbObject.new(nil, drb_uri)
  
  cli = Testjour::CucumberCli.new(queue_server, step_mother)
  cli.require_steps("./features/steps/*.rb")

  begin
    loop do
      begin
        file = queue_server.take_work
        Testjour.logger.debug "Running feature file: #{file}"
        cli.run_file(file)
      rescue Testjour::QueueServer::NoWorkUnitsAvailableError
        # If no work, ignore and keep looping
      end
    end
  rescue DRb::DRbConnError
    Testjour.logger.info "DRb connection error. Exiting runner."
  end
  
end

