require "testjour/commands/command"
require "testjour/mysql"

module Testjour
module Commands
    
  class MysqlDrop < Command
    
    def execute
      configuration.parse!
      
      Testjour.logger.info "Starting mysql:drop. Args: #{@args.inspect}"
      require "active_record"

      ActiveRecord::Base.establish_connection({
        :username => "root",
        :database => "information_schema",
        :host     => "localhost",
        :adapter  => "mysql"
      })

      ActiveRecord::Base.connection.execute "DROP DATABASE #{@args.first}"
      return 0
    rescue Object => ex  
      Testjour.logger.error "mysql:drop error: #{ex.message}"
      Testjour.logger.error ex.backtrace.join("\n")
      return 1
    end
    
  end
  
end
end