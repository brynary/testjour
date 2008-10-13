require "rubygems"
require "English"
require "logger"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

module Testjour
  VERSION = '0.1.0'
  
  class << self
    attr_accessor :step_mother
    attr_accessor :executor
  end
  
  def self.load_cucumber
    $LOAD_PATH.unshift(File.expand_path("./vendor/plugins/cucumber/lib"))
    
    require "cucumber"
    require "cucumber/formatters/ansicolor"
    require "cucumber/treetop_parser/feature_en"
    Cucumber.load_language("en")
    
    # Expose this because we need it
    class << Cucumber::CLI
      attr_reader :executor
      attr_reader :step_mother
    end
  end
  
  def self.logger
    return @logger if @logger
    setup_logger
    @logger
  end
  
  def self.setup_logger
    @logger = Logger.new("testjour.log")
    @logger.formatter = proc { |severity, time, progname, msg| "#{time.strftime("%b %d %H:%M:%S")} [#{$PID}]: #{msg}\n" }
    @logger.level = Logger::DEBUG
  end
  
end