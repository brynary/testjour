require "rubygems"

require File.expand_path(File.dirname(__FILE__) + "/testjour/core_extensions")
require File.expand_path(File.dirname(__FILE__) + "/testjour/drb_servers")
require File.expand_path(File.dirname(__FILE__) + "/testjour/jour")
require File.expand_path(File.dirname(__FILE__) + "/testjour/rsync")
require File.expand_path(File.dirname(__FILE__) + "/testjour/mysql_database")
require File.expand_path(File.dirname(__FILE__) + "/testjour/cucumber_extensions")
require File.expand_path(File.dirname(__FILE__) + "/testjour/transat")
require File.expand_path(File.dirname(__FILE__) + "/testjour/commands")

Cucumber.disable_run

require "cucumber/formatters/ansicolor"

require "logger"
require 'English'

module Testjour
  VERSION = '1.0.0'
  
  def self.logger
    return @logger if @logger
    @logger = Logger.new("log/testjour.log")
    @logger.formatter = proc { |severity, time, progname, msg| "#{time.strftime("%b %d %H:%M:%S")} [#{$PID}]: #{msg}\n" }
    @logger.level = Logger::DEBUG # ENV["TESTJOUR_LOG"] || Logger::INFO
    @logger
  end
  
  class Colorer
    extend ::Cucumber::Formatters::ANSIColor
  end
  
  CommandLineProcessor = Transat::Parser.new do
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