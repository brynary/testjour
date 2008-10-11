$:.unshift(File.expand_path("./vendor/plugins/cucumber/lib"))

require "rubygems"
require "English"
require "optparse"
require "logger"
require "drb"
require "daemons/daemonize"

require "cucumber"
require "cucumber/formatters/ansicolor"
require "cucumber/treetop_parser/feature_en"
Cucumber.load_language("en")

require File.expand_path(File.dirname(__FILE__) + "/testjour/cucumber_extensions/drb_formatter")
require File.expand_path(File.dirname(__FILE__) + "/testjour/cucumber_extensions/queueing_executor")
require File.expand_path(File.dirname(__FILE__) + "/testjour/core_extensions")
require File.expand_path(File.dirname(__FILE__) + "/testjour/queue_server")
require File.expand_path(File.dirname(__FILE__) + "/testjour/slave_server")
require File.expand_path(File.dirname(__FILE__) + "/testjour/jour")
require File.expand_path(File.dirname(__FILE__) + "/testjour/rsync")
require File.expand_path(File.dirname(__FILE__) + "/testjour/mysql_database")
require File.expand_path(File.dirname(__FILE__) + "/testjour/commands")
require File.expand_path(File.dirname(__FILE__) + "/testjour/cli")

module Testjour
  VERSION = '1.0.0'
  
  class << self
    attr_accessor :step_mother
    attr_accessor :executor
  end
  
  def self.logger
    return @logger if @logger
    @logger = Logger.new("log/testjour.log")
    @logger.formatter = proc { |severity, time, progname, msg| "#{time.strftime("%b %d %H:%M:%S")} [#{$PID}]: #{msg}\n" }
    @logger.level = Logger::DEBUG
    @logger
  end
  
  class Colorer
    extend ::Cucumber::Formatters::ANSIColor
  end
  
  CommandLineProcessor = Testjour::CLI::Parser.new do
    program_name "Testjour"
    version [Testjour::VERSION]

    option :chdir,  :short => :c, :param_name => "PATH",    :message => "Change to dir before starting (will be expanded)."
    # option :force,  :short => :f, :message => "Force the shutdown (kill -9)."
    option :pid,    :short => :P, :param_name => "FILE",    :message => "Where the PID file is located."
    option :queue,  :short => :q, :param_name => "DRB_URI", :message => "Where to grab the work"

    command "run",  Testjour::Commands::Run
    command "list", Testjour::Commands::List
    
    command "slave:start",  Testjour::Commands::SlaveStart,  :valid_options => %w[chdir pid]
    command "slave:stop",   Testjour::Commands::SlaveStop,  :valid_options => %w[chdir pid]
    command "slave:run",    Testjour::Commands::SlaveRun, :valid_options => %w[chdir queue working_dir]
  end
end

Testjour.executor = executor
Testjour.step_mother = step_mother