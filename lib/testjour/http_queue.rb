require "testjour/core_extensions/wait_for_service"
require "curb"

module Testjour
  class HttpQueue
    class ResultOverdueError < StandardError; end
    
    class QueueProxy
      
      def initialize(uri = nil)
        @uri = uri
      end
      
      def uri
        @uri || "http://0.0.0.0:#{Testjour::HttpQueue.port}/"
      end
      
      def push(queue_name, data)
        c = Curl::Easy.http_post(uri + queue_name.to_s,
          Curl::PostField.content("data",  Marshal.dump(data)))
          
        c.response_code == 200
      end
      
      def pop(queue_name)
        c = Curl::Easy.new(uri + queue_name.to_s)
        c.perform
        
        if c.response_code == 200
          return Marshal.load(c.body_str)
        elsif c.response_code == 404
          return nil
        else
          raise "Bad response: #{c.body_str}"
        end
      end
      
    protected
    
      def self.with_net_http(&block)
        Net::HTTP.start("0.0.0.0", HttpQueue.port, &block)
      end
      
    end
    
    def self.timeout_in_seconds
      180
    end
    
    def self.run_on(handler)
      handler.run self, :Port => port
    end
    
    def self.wait_for_service
      TCPSocket.wait_for_service :host => "0.0.0.0", :port => port
    end
    
    def self.wait_for_no_service
      TCPSocket.wait_for_no_service :host => "0.0.0.0", :port => port
    end
    
    def self.with_queue(uri = nil, &block)
      yield QueueProxy.new(uri)
    end
    
    def self.with_queue_server
      existing_pid = `ps | grep httpq | grep -v grep`.strip.split.first
      
      if existing_pid
        Testjour.logger.info "Killing running httpq PID #{existing_pid}..."
        Process.kill("INT", existing_pid.to_i)
        HttpQueue.wait_for_no_service
      end
      
      Testjour.logger.info "Starting httpq..."
      pid = detached_exec(File.expand_path(File.dirname(__FILE__) + "/../../bin/httpq"))
      kill_at_exit(pid)
      wait_for_service
      
      Testjour.logger.info "Started httpq."
      
      yield
    end
    
    def self.kill_at_exit(pid)
      at_exit do
        Process.kill("INT", pid)
      end
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
      else error("unknown path: #{request.path_info}")
      end
    end
  
    def handle_post
      case request.path_info
      when "/feature_files" then push(:feature_files)
      when "/results"       then push(:results)
      else error("unknown path: #{request.path_info}")
      end
    end
  
    def reset
      self.class.queues.each do |name, queue|
        queue.clear
      end
      
      ok
    end
  
    def pop(queue_name, non_block = true)
      data = nil
      
      begin
        data = Timeout.timeout(self.class.timeout_in_seconds, ResultOverdueError) do
          queue(queue_name).pop(non_block)
        end
      rescue ResultOverdueError
        return error("result overdue")
      end
      
      [200, { "Content-Type" => "text/plain" }, data]
    rescue ThreadError => ex
      if ex.message =~ /queue empty/
        missing
      else
        error("uncaught exception")
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
  
    def error(message = nil)
      [500, { "Content-Type" => "text/plain" }, "Server error: #{message}"]
    end
  
  end
end