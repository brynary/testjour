require "testjour/core_extensions/wait_for_service"
require "net/http"

module Testjour
  class HttpQueue
    class ResultOverdueError < StandardError; end
    
    class QueueProxy
      
      def push(queue_name, data)
        self.class.with_net_http do |http|
          request = Net::HTTP::Post.new("/" + queue_name.to_s)
          request.form_data = { "data" => data }
          response  = http.request(request)
          return response.code.to_i == 200
        end
      end
      
      def pop(queue_name)
        self.class.with_net_http do |http|
          request = Net::HTTP::Get.new("/" + queue_name.to_s)
          response = http.request(request)
          
          if response.code.to_i == 200
            return response.body
          else
            return nil
          end
        end
      end
      
    protected
    
      def self.with_net_http(&block)
        Net::HTTP.start("0.0.0.0", HttpQueue.port, &block)
      end
      
    end
    
    def self.timeout_in_seconds
      60
    end
    
    def self.run_on(handler)
      handler.run self, :Port => port
    end
    
    def self.wait_for_service
      TCPSocket.wait_for_service :host => "0.0.0.0", :port => port
    end
    
    def self.with_queue(&block)
      yield QueueProxy.new
    end
    
    def self.with_queue_server
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
      when "/results"       then pop(:results, false)
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
  
    def pop(queue_name, non_block = true)
      data = Timeout.timeout(self.class.timeout_in_seconds, ResultOverdueError) do
        queue(queue_name).pop(non_block)
      end
      
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