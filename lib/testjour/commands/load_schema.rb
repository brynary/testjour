require "testjour/commands/command"
require "testjour/mysql"

module Testjour
module Commands
    
  class LoadSchema < Command
    
    def execute
      Testjour.logger.info "Starting load:schema"
      ENV["RAILS_ENV"] = "integration"
      require File.expand_path("./config/environment")
      Testjour.logger.info "Loaded env"
      database_name = @args.first
      Testjour.logger.info "loading schema into: #{database_name}"
      mysql = MysqlDatabaseSetup.new(database_name)
      mysql.load_schema
      return 0
    rescue Object => ex  
      Testjour.logger.error "load:schema error: #{ex.message}"
      Testjour.logger.error ex.backtrace.join("\n")
      return 1
    end
    
  end
  
end
end