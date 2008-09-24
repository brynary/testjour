require "rubygems"

require File.expand_path(File.dirname(__FILE__) + "/testjour/object_extensions")
require File.expand_path(File.dirname(__FILE__) + "/testjour/queue_server")
require File.expand_path(File.dirname(__FILE__) + "/testjour/slave_server")
require File.expand_path(File.dirname(__FILE__) + "/testjour/jour")
require File.expand_path(File.dirname(__FILE__) + "/testjour/mysql_database")
require File.expand_path(File.dirname(__FILE__) + "/testjour/cucumber_extensions")

module Testjour
  VERSION = '1.0.0'
end