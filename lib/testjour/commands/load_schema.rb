require "testjour/commands/command"
require "testjour/mysql"

module Testjour
module Commands
    
  class LoadSchema < Command
    
    def execute
      require File.expand_path("./config/environment")
      database_name = @args.first
      mysql = MysqlDatabaseSetup.new(database_name)
      mysql.load_schema
      return 0
    end
    
  end
  
end
end