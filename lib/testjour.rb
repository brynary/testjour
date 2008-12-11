require "rubygems"
require "English"
require "logger"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

module Kernel
  # Options:
  # * :tries - Number of retries to perform. Defaults to 1.
  # * :on - The Exception on which a retry will be performed. Defaults to Exception, which retries on any Exception.
  #
  # Example
  # =======
  #   retryable(:tries => 1, :on => OpenURI::HTTPError) do
  #     # your code here
  #   end
  #
  def retryable(options = {}, &block)
    opts = { :tries => 1, :on => Exception }.merge(options)

    retry_exception, retries = opts[:on], opts[:tries]

    begin
      return yield
    rescue retry_exception
      retry if (retries -= 1) > 0
    end

    yield
  end
end

module Testjour
  VERSION = '0.2.0'
  
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