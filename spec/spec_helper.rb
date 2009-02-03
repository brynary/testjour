require "rubygems"
require "spec"
require "fileutils"
require "net/http"

require File.expand_path(File.dirname(__FILE__) + "/../lib/testjour")
require "testjour/http_queue"

Spec::Runner.configure do |config|

  def start_queue
    $tjqueue_pid = fork do
      Dir.chdir(File.join(File.dirname(__FILE__), "..", "bin"))
      
      silence_stream(STDOUT) do
        silence_stream(STDERR) do
          exec "ruby httpq"
        end
      end
    end
    
    Testjour::HttpQueue.wait_for_service
  end
  
  def shutdown_queue
    Process.kill 9, $tjqueue_pid
    Process.wait($tjqueue_pid)
  end
  
  def get(path)
    require "curb"
    
    @response = Curl::Easy.new("http://0.0.0.0:#{Testjour::HttpQueue.port}" + path)
    @response.perform
    @response_code = @response.response_code
  end
  
  def post(path)
    require "curb"
    
    @response = Curl::Easy.http_post("http://0.0.0.0:#{Testjour::HttpQueue.port}" + path)
    @response.perform
    @response_code = @response.response_code
  end
  
  def response
    @response
  end
  
end