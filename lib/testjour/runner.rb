#!/usr/bin/env ruby

require File.expand_path("./vendor/plugins/cucumber/lib/cucumber")
require File.expand_path(File.dirname(__FILE__) + "/../testjour")

# Trick Cucumber into not runing anything itself
module Cucumber
 class CLI
   def self.execute_called?
     true
    end
  end
end

module Testjour
  
  class CucumberCli
  
    def initialize(queue_server, step_mother)
      @queue_server = queue_server
      
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

Testjour::MysqlDatabaseSetup.with_new_database do
  DRb.start_service
  queue_server = DRbObject.new(nil, ARGV.shift)

  extend Cucumber::StepMethods
  extend Cucumber::Tree
  
  cli = Testjour::CucumberCli.new(queue_server, step_mother)
  cli.require_steps("./features/steps/*.rb")

  begin
    loop do
      begin
        cli.run_file(queue_server.take_work)
      rescue Testjour::QueueServer::NoWorkUnitsAvailableError
        # If no work, ignore and keep looping
      end
    end
  rescue DRb::DRbConnError
    # DRb server shutdown - we're done
  end
  
end

