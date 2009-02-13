module Testjour
  
  # Stolen from deep-test
  
  class MysqlDatabaseSetup

    def initialize(runner_database_name = nil)
      @runner_database_name = runner_database_name
    end
    
    def create_database
      # cmd = "mysqladmin create -uroot #{runner_database_name}"
      cmd = "testjour mysql:create #{runner_database_name}"
      Testjour.logger.info "Creating DB: #{cmd}"
      status, stdout, stderr = systemu(cmd)
      exit_code = status.exitstatus
      
      if exit_code.zero?
        Testjour.logger.info "Success"
      else
        Testjour.logger.info "Failed: #{exit_code}"
        Testjour.logger.info stderr
        Testjour.logger.info stdout
      end
    end
    
    def drop_database
      cmd = "echo y | mysqladmin drop -uroot #{runner_database_name}"
      Testjour.logger.info "Dropping DB: #{cmd}"
      system cmd
    end

    def load_schema
      ActiveRecord::Base.establish_connection(database_configuration)
      
      dir = defined?(RAILS_ROOT) ? RAILS_ROOT : "."
      load File.join(dir, "db", "schema.rb")
    end
    
    def runner_database_name
      @runner_database_name ||= "testjour_runner_#{rand(1_000)}"
    end
    
  protected
  
    def database_configuration
      {
        :adapter  => "mysql",
        :host     => "localhost",
        :username => "root",
        :database => runner_database_name
      }
    end
    
  end
  
end

