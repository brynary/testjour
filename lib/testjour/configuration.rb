module Testjour

  class Configuration
    attr_reader :unknown_args, :options, :path, :queue_uri, :full_uri

    def initialize(args)
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

    def max_local_slaves
      @options[:max_local_slaves] || 2
    end

    def in
      @options[:in]
    end

    def rsync_uri
      full_uri.user + "@" + full_uri.host + ":" + full_uri.path
    end

    def remote_slaves
      @options[:slaves] || []
    end

    def setup_mysql
      return unless mysql_mode?

      mysql = MysqlDatabaseSetup.new

      mysql.create_database
      at_exit do
        Testjour.logger.info caller.join("\n")
        mysql.drop_database
      end

      ENV["TESTJOUR_DB"] = mysql.runner_database_name
      mysql.load_schema
    end

    def files_to_require
      cucumber_configuration.files_to_require
    end

    def step_mother
      Cucumber::Cli::Main.instance_variable_get("@step_mother")
    end

    def mysql_mode?
      @options[:create_mysql_db]
    end

    def local_slave_count
      [feature_files.size, max_local_slaves].min
    end

    def parser
      @parser ||= Cucumber::Parser::FeatureParser.new
    end

    def load_plain_text_features(files)
      features = Cucumber::Ast::Features.new

      Array(files).each do |file|
        parsed_feature = parser.parse_file(file, cucumber_configuration.options)

        if parsed_feature
          features.add_feature(parsed_feature)
        end
      end

      return features
    end

    def feature_files
      return @feature_files if @feature_files

      features = load_plain_text_features(cucumber_configuration.feature_files)
      visitor = Testjour::FeatureFileFinder.new(step_mother)
      visitor.options = cucumber_configuration.options
      visitor.visit_features(features)
      @feature_files = visitor.feature_files

      return @feature_files
    end

    def cucumber_configuration
      return @cucumber_configuration if @cucumber_configuration
      @cucumber_configuration = Cucumber::Cli::Configuration.new(StringIO.new, StringIO.new)
      Testjour.logger.info "Arguments for Cucumber: #{args_for_cucumber.inspect}"
      @cucumber_configuration.parse!(args_for_cucumber)
      @cucumber_configuration
    end

    def unshift_args(pushed_args)
      pushed_args.each do |pushed_arg|
        @args.unshift(pushed_arg)
      end
    end

    def parse!
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

        opts.on("--max-local-slaves=MAX", "Maximum number of local slaves") do |max|
          @options[:max_local_slaves] = max.to_i
        end
      end
    end
  end

end