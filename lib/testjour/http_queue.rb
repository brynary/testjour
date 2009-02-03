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
    
    def self.queues
      @queues ||= {
        :feature_files  => Queue.new,
        :results        => Queue.new
      }
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
      when "/reset"         then reset
      when "/feature_files" then pop(:feature_files)
      when "/results"       then pop(:results)
      else error
      end
    end
  
    def handle_post
      case request.path_info
      when "/feature_files" then push(:feature_files)
      when "/results"       then push(:results)
      else error
      end
    end
  
    def reset
      self.class.queues.each do |name, queue|
        queue.clear
      end
      
      ok
    end
  
    def pop(queue_name)
      data = queue(queue_name).pop(true)
      [200, { "Content-Type" => "text/plain" }, data]
    rescue ThreadError => ex
      if ex.message =~ /queue empty/
        missing
      else
        raise
      end
    end
  
    def push(queue_name)
      queue(queue_name).push(request.POST["data"])
      ok
    end
  
    def queue(name)
      self.class.queues[name]
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