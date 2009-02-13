module Testjour
  
  class Configuration
    attr_reader :unknown_args, :options, :path, :queue_uri, :full_uri
  
    def initialize(args)
      @max_local_slaves = 2
      @options = {}
      @args = args
      @unknown_args = []
    end
    
    def setup
      require 'cucumber/cli/main'
      Cucumber.class_eval do
        def language_incomplete?
          false
        end
      end
      Cucumber.load_language("en")
      step_mother.options = cucumber_configuration.options
    end

    def setup_mysql
      if mysql_mode?
        Testjour.logger.info "Setting up mysql"
        setup_mysql 
      else
        Testjour.logger.info "Skipping mysql setup"
      end
    end
    
    def in
      @options[:in]
    end
    
    def rsync_uri
      # require "rubygems"; require "ruby-debug"; Debugger.start; debugger
      full_uri.user + "@" + full_uri.host + ":" + full_uri.path
    end
    
    def remote_slaves
      @options[:slaves] || []
    end
    
    def setup_mysql
      mysql = MysqlDatabaseSetup.new
      
      Testjour.logger.info "Creating mysql db"
      
      mysql.create_database
      ENV["TESTJOUR_DB"] = mysql.runner_database_name
      
      if File.exist?(File.expand_path("./db/schema.rb"))
        cmd = schema_load_command(mysql.runner_database_name)
        Testjour.logger.info "Loading schema: #{cmd}"
        silence_stream(STDOUT) do
          system schema_load_command(mysql.runner_database_name)
        end
      else
        Testjour.logger.info "Skipping load schema. #{File.expand_path("./db/schema.rb")} doesn't exist"
      end
          
      # at_exit do
      #   mysql.drop_database
      # end
    end
    
    def schema_load_command(database_name)
      "testjour mysql:load_schema #{database_name}"
    end
    
    def files_to_require
      cucumber_configuration.files_to_require
    end
    
    def step_mother
      Cucumber::Cli::Main.instance_variable_get("@step_mother")
    end
  
    def ast_filter
      cucumber_configuration.ast_filter
    end
    
    def mysql_mode?
      return true if @options[:create_mysql_db]
      return false unless File.exist?("testjour.yml")
      testjour_yml = File.read("testjour.yml")
      testjour_yml.include?("--create-mysql-db")
    end
    
    def local_slave_count
      return 0 if remote_slaves.any?
      [feature_files.size, @max_local_slaves].min
    end
    
    def feature_files
      cucumber_configuration.feature_files
    end
    
    def cucumber_configuration
      return @cucumber_configuration if @cucumber_configuration
      @cucumber_configuration = Cucumber::Cli::Configuration.new(StringIO.new, StringIO.new)
      Testjour.logger.info "Arguments for Cucumber: #{args_for_cucumber.inspect}"
      @cucumber_configuration.parse!(args_for_cucumber)
      @cucumber_configuration
    end
  
    def parse!
      Testjour.logger.info "Parsing options: #{@args.inspect}"
      
      begin
        option_parser.parse!(@args)
      rescue OptionParser::InvalidOption => e
        e.recover @args
        saved_arg = @args.shift
        @unknown_args << saved_arg

        if @args.any? && !saved_arg.include?("=") && @args.first[0..0] != "-"
          @unknown_args << @args.shift
        end

        retry
      end
      
      Testjour.logger.info "Options: #{@options.inspect}"
    end
  
    def parse_uri!
      full_uri = URI.parse(@args.shift)
      @path = full_uri.path
      @full_uri = full_uri.dup
      full_uri.path = "/"
      @queue_uri = full_uri.to_s
    end
    
    def run_slave_args
      [testjour_args + @unknown_args]
    end
  
    def testjour_args
      args_from_options = []
      if @options[:create_mysql_db]
        args_from_options << "--create-mysql-db"
      end
      return args_from_options
    end
  
    def args_for_cucumber
      @unknown_args + @args
    end
  
  protected
  
    def option_parser
      OptionParser.new do |opts|
        opts.on("--on=SLAVE", "Specify a slave URI") do |slave|
          @options[:slaves] ||= []
          @options[:slaves] << slave
        end
        
        opts.on("--in=DIR", "Working directory to use (for run:remote only)") do |directory|
          @options[:in] = directory
        end
        
        opts.on("--create-mysql-db", "Create MySQL for each slave") do |server|
          @options[:create_mysql_db] = true
        end
      end
    end
  end
  
end