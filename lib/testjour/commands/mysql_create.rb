require "testjour/commands/base_command"
require "testjour/mysql"

module Testjour
  module CLI
    
    class MysqlCreate < BaseCommand
      
      def self.command
        "mysql:create"
      end
      
      def initialize(*args)
        super
        Testjour.logger.debug "Runner command #{self.class}..."
      end
      
      def run
        mysql = MysqlDatabaseSetup.new
        mysql.create_database
        
        ENV["TESTJOUR_DB"] = mysql.runner_database_name
        ENV["RAILS_ENV"] ||= "test"
        require File.expand_path("./config/environment")
        
        mysql.connect
        mysql.load_schema

        puts mysql.runner_database_name
      end
      
    end
   
  end
end