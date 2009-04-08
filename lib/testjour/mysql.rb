module Testjour
  
  # Stolen from deep-test
  
  class MysqlDatabaseSetup

    def initialize(runner_database_name = nil)
      @runner_database_name = runner_database_name
    end
    
    def create_database
      run "/usr/local/mysql/bin/mysqladmin create #{runner_database_name}"
    end
    
    def drop_database
      run "/usr/local/mysql/bin/mysqladmin -f drop #{runner_database_name}"
    end

    def load_schema
      schema_file = File.expand_path("./db/development_structure.sql")
      
      unless File.exist?(schema_file)
      end
      
      run "/usr/local/mysql/bin/mysql #{runner_database_name} < #{schema_file}"
    end
    
    def runner_database_name
      @runner_database_name ||= "testjour_runner_#{rand(1_000)}"
    end
    
  protected
  
    def run(cmd)
      Testjour.logger.info "Executing: #{cmd}"
      status, stdout, stderr = systemu(cmd)
      exit_code = status.exitstatus
    
      unless exit_code.zero?
        Testjour.logger.info "Failed: #{exit_code}"
        Testjour.logger.info stderr
        Testjour.logger.info stdout
      end
    end
    
  end
  
end

