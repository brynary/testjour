require "rubygems"

require File.expand_path(File.dirname(__FILE__) + "/testjour/object_extensions")
require File.expand_path(File.dirname(__FILE__) + "/testjour/queue_server")
require File.expand_path(File.dirname(__FILE__) + "/testjour/slave_server")
require File.expand_path(File.dirname(__FILE__) + "/testjour/jour")
require File.expand_path(File.dirname(__FILE__) + "/testjour/rsync")
require File.expand_path(File.dirname(__FILE__) + "/testjour/mysql_database")
require File.expand_path(File.dirname(__FILE__) + "/testjour/cucumber_extensions")

require "logger"
require 'English'

module Testjour
  VERSION = '1.0.0'
  
  def self.logger
    return @logger if @logger
    @logger = Logger.new("log/testjour.log")
    @logger.formatter = proc { |severity, time, progname, msg| "#{time.strftime("%b %d %H:%M:%S")} [#{$PID}]: #{msg}\n" }
    @logger.level = Logger::DEBUG
    @logger
  end
  
end