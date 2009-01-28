require "testjour/commands/base_command"
require "testjour/mysql"

module Testjour
  module CLI
    
    class MysqlDrop < BaseCommand
      
      def self.command
        "mysql:drop"
      end
      
      def initialize(*args)
        super
        Testjour.logger.debug "Runner command #{self.class}..."
        
        ENV["RAILS_ENV"] ||= "test"
        require File.expand_path("./config/environment")
      end
      
      def run
        database_name = @non_options.shift
        mysql = MysqlDatabaseSetup.new(database_name)
        mysql.connect
        mysql.drop_database
      end
      
    end
   
  end
end