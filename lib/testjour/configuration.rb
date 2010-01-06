module Testjour

  class Configuration
    attr_reader :unknown_args, :options, :path, :full_uri

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
      # Cucumber.load_language("en")
      step_mother.options = cucumber_configuration.options
    end

    def max_local_slaves
      @options[:max_local_slaves] || 2
    end

    def in
      @options[:in]
    end

    def rsync_uri
      external_rsync_uri || "#{full_uri.user}#{'@' if full_uri.user}#{full_uri.host}:#{full_uri.path}"
    end

    def external_rsync_uri
      @options[:rsync_uri]
    end

    def queue_host
      @queue_host || @options[:queue_host] || Testjour.socket_hostname
    end

    def queue_prefix
      @options[:queue_prefix] || 'default'
    end
    
    def queue_timeout
      @options[:queue_timeout].to_i || 270
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

    def step_mother
      Cucumber::Cli::Main.step_mother
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

      Array(files).each do |f|
        feature_file = Cucumber::FeatureFile.new(f)
        feature = feature_file.parse(step_mother, cucumber_configuration.options)
        if feature
          features.add_feature(feature)
        end
      end

      return features
    end

    def feature_files
      return @feature_files if @feature_files

      features = load_plain_text_features(cucumber_configuration.feature_files)
      finder = Testjour::FeatureFileFinder.new
      walker = Cucumber::Ast::TreeWalker.new(step_mother, [finder])
      walker.options = cucumber_configuration.options
      walker.visit_features(features)
      @feature_files = finder.feature_files

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

    def load_additional_args_from_external_file
      args_from_file = begin
        if File.exist?(args_file)
          File.read(args_file).strip.split
        else
          []
        end
      end
      unshift_args(args_from_file)
    end

    def args_file
      # We need to know about this CLI option prior to OptParse's parse
      args_file_option = @args.detect{|arg| arg =~ /^--testjour-config=/}
      if args_file_option
        args_file_option =~ /^--testjour-config=(.*)/
        $1
      else
        'testjour.yml'
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
      @queue_host = full_uri.host
    end

    def run_slave_args
      [testjour_args + @unknown_args]
    end

    def testjour_args
      args_from_options = []
      if @options[:create_mysql_db]
        args_from_options << "--create-mysql-db"
      end
      if @options[:queue_host]
        args_from_options << "--queue-host=#{@options[:queue_host]}"
      end
      if @options[:queue_prefix]
        args_from_options << "--queue-prefix=#{@options[:queue_prefix]}"
      end
      return args_from_options
    end

    def args_for_cucumber
      @unknown_args + @args
    end

  protected

    def option_parser
      OptionParser.new do |opts|
        opts.on("--testjour-config=ARGS_FILE", "Load additional testjour args from the specified file (defaults to testjour.yml)") do |args_file|
          @options[:args_file] = args_file
        end

        opts.on("--on=SLAVE", "Specify a slave URI") do |slave|
          @options[:slaves] ||= []
          @options[:slaves] << slave
        end

        opts.on("--in=DIR", "Working directory to use (for run:remote only)") do |directory|
          @options[:in] = directory
        end

        opts.on("--strict", "Fail if there are any undefined steps") do
          @options[:strict] = true
        end

        opts.on("--create-mysql-db", "Create MySQL for each slave") do
          @options[:create_mysql_db] = true
        end

        opts.on("--simple-progress", "Use a simpler progress bar that may display better in logs") do
          @options[:simple_progress] = true
        end

        opts.on("--queue-host=QUEUE_HOST", "Use another server to host the main redis queue") do |queue_host|
          @options[:queue_host] = queue_host
        end

        opts.on("--queue-prefix=QUEUE_PREFIX", "Provide a prefix to uniquely identify this testjour run (Default is 'default')") do |queue_prefix|
          @options[:queue_prefix] = queue_prefix
        end

        opts.on("--queue-timeout=QUEUE_TIMEOUT", "How long to wait for results to appear in the queue before giving up") do |queue_timeout|
          @options[:queue_timeout] = queue_timeout
        end

        opts.on("--rsync-uri=RSYNC_URI", "Use another location to host the codebase for slave rsync (master will rsync to this URI first)") do |rsync_uri|
          @options[:rsync_uri] = rsync_uri
        end

        opts.on("--max-local-slaves=MAX", "Maximum number of local slaves") do |max|
          @options[:max_local_slaves] = max.to_i
        end
      end
    end
  end

end