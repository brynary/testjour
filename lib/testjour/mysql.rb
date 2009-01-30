RAILS_ROOT = File.expand_path(".") unless defined?(RAILS_ROOT)

module Testjour
  
  # Stolen from deep-test
  
  class MysqlDatabaseSetup

    def initialize(runner_database_name = nil)
      @runner_database_name = runner_database_name
    end
    
    def create_database
      system "mysqladmin create -uroot #{runner_database_name}"
    end
    
    def drop_database
      system "echo y | mysqladmin drop -uroot #{runner_database_name}"
    end

    def connect
      ActiveRecord::Base.establish_connection(database_configuration)
    end

    def load_schema
      # silence_stream(STDOUT) do
        load File.join(RAILS_ROOT, "db", "schema.rb")
      # end
    end
    
    def runner_database_name
      @runner_database_name ||= "testjour_runner_#{rand(1_000)}"
    end
    
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

