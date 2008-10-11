module Testjour
  
  class Command
      
    def initialize(non_options, options)
      @non_options = non_options
      @options = options
    end
    
    def run
    end
    
  end
  
end

require File.expand_path(File.dirname(__FILE__) + "/commands/run")
require File.expand_path(File.dirname(__FILE__) + "/commands/list")
require File.expand_path(File.dirname(__FILE__) + "/commands/slave_start")
require File.expand_path(File.dirname(__FILE__) + "/commands/slave_stop")
require File.expand_path(File.dirname(__FILE__) + "/commands/slave_run")