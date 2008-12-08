module Testjour
  
  # Stolen from deep-test
  
  class MysqlDatabaseSetup
    class << self
      #
      # ActiveRecord configuration to use when connecting to
      # MySQL to create databases, drop database, and grant
      # privileges.  By default, connects to information_schema
      # on localhost as root with no password.
      #
      attr_accessor :admin_configuration
    end
    
    self.admin_configuration = {
      :adapter  => "mysql",
      :host     => "localhost",
      :username => "root",
      :database => "information_schema"
    }

    def self.with_new_database
      mysql = self.new
      mysql.create_database
      
      at_exit do
        mysql.drop_database
      end
      
      mysql.connect
      mysql.load_schema
      
      yield
    end

    def grant_privileges(connection)
      sql = %{grant all on #{runner_database_name}.* 
          to %s@'localhost' identified by %s;} % [
        connection.quote(self.class.admin_configuration[:username]),
        connection.quote(self.class.admin_configuration[:password] || "")
      ]
      connection.execute sql
    end
    
    def create_database
      admin_connection do |connection|
        connection.recreate_database runner_database_name
        grant_privileges(connection)
      end
    end
    
    def drop_database
      admin_connection do |connection|
        connection.drop_database runner_database_name
      end
    end

    def connect
      ActiveRecord::Base.establish_connection(self.class.admin_configuration.merge(:database => runner_database_name))
    end

    def load_schema
      # silence_stream(STDOUT) do
        load File.join(RAILS_ROOT, "db", "schema.rb")
      # end
    end

    def admin_connection
      conn = ActiveRecord::Base.mysql_connection(self.class.admin_configuration)
      yield conn
    ensure
      conn.disconnect! if conn
    end
    
    def runner_database_name
      @runner_database_name ||= "testjour_runner_#{rand(1_000)}"
    end
  end
  
end

