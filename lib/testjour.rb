require "rubygems"
require "English"
require "logger"

$LOAD_PATH.unshift(File.expand_path("./vendor/plugins/cucumber/lib"))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require "cucumber"
require "cucumber/formatters/ansicolor"
require "cucumber/treetop_parser/feature_en"
Cucumber.load_language("en")

# Expose this because we need it
module Cucumber
  class << CLI
    attr_reader :executor
  end
end

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
end

Testjour.executor = executor
Testjour.step_mother = step_mother