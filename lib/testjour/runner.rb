#!/usr/bin/env ruby

require "optparse"

options = { :drb_uri => nil, :project_path => "."}
ARGV.extend(OptionParser::Arguable)
ARGV.options do |opts|
  opts.on("-q URI", "--queue URI", "Where to grab work from") do |v|
    options[:drb_uri] = v
  end
  
  opts.on("-d PROJECT_DIR", "--working-dir PROJECT_DIR", "Which dir to run in") do |v|
    options[:project_path] = v
  end
end.parse!

options[:project_path] = File.expand_path(options[:project_path])

require File.expand_path(options[:project_path] + "/vendor/plugins/cucumber/lib/cucumber")
require File.expand_path(File.dirname(__FILE__) + "/../testjour")

Testjour.logger.debug "Runner starting..."

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
require File.expand_path(options[:project_path] + '/config/environment')

# Testjour::Rsync.sync(options[:drb_uri], options[:project_path], File.expand_path("~/temp3"))

Testjour::MysqlDatabaseSetup.with_new_database do
  DRb.start_service
  queue_server = DRbObject.new(nil, options[:drb_uri])
  
  cli = Testjour::CucumberCli.new(queue_server, step_mother)
  cli.require_steps(File.expand_path(options[:project_path] + "/features/steps/*.rb"))

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
    Testjour.logger.debug "DRb connection error. Exiting runner."
  end
  
end

