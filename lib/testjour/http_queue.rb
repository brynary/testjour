require "testjour/core_extensions/wait_for_service"

module Testjour
  class HttpQueue

    def self.run_on(handler)
      handler.run self, :Port => port
    end
    
    def self.wait_for_service
      TCPSocket.wait_for_service :host => "0.0.0.0", :port => port
    end
    
    def self.with_net_http(&block)
      Net::HTTP.start("0.0.0.0", port, &block)
    end
    
    def self.with_queue
      pid = fork do
        exec File.expand_path(File.dirname(__FILE__) + "/../../bin/httpq")
      end
      
      Process.detach(pid)
      at_exit do
        Process.kill("INT", pid)
      end
      
      wait_for_service
      
      yield
    end
    
    def self.port
      15434
    end
    
    def self.feature_files_queue
      @feature_files_queue ||= Queue.new
    end

    def self.call(env)
      new(env).call
    end
  
    def initialize(env)
      @request = Rack::Request.new(env)
    end
  
    def call
      if request.post?
        handle_post
      else
        handle_get
      end
    end
  
  protected
  
    def request
      @request
    end
  
    def handle_get
      case request.path_info
      when "/reset" then reset
      when "/feature_files"      then pop
      else error
      end
    end
  
    def handle_post
      case request.path_info
      when "/feature_files"  then push
      else error
      end
    end
  
    def reset
      feature_files.clear
      ok
    end
  
    def pop
      feature = feature_files.pop(true)
      [200, { "Content-Type" => "text/plain" }, feature]
    rescue ThreadError => ex
      if ex.message =~ /queue empty/
        missing
      else
        raise
      end
    end
  
    def push
      feature_files.push(request.POST["data"])
      ok
    end
  
    def feature_files
      self.class.feature_files_queue
    end
    
    def ok
      [200, { "Content-Type" => "text/plain" }, "OK"]
    end
  
    def missing
      [404, { "Content-Type" => "text/plain" }, "Not Found"]
    end
  
    def error
      [500, { "Content-Type" => "text/plain" }, "Server error"]
    end
  
  end
end