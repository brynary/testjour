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
      exec "ruby httpq"
    end
    
    Testjour::HttpQueue.wait_for_service
  end
  
  def shutdown_queue
    Process.kill "INT", $tjqueue_pid
    Process.wait($tjqueue_pid)
  end
  
  def get(path)
    Testjour::HttpQueue::QueueProxy.with_net_http do |http|
      get = Net::HTTP::Get.new(path)
      @response = http.request(get)
    end
  end
  
  def post(path, data = {})
    Testjour::HttpQueue::QueueProxy.with_net_http do |http|
      post = Net::HTTP::Post.new(path)
      post.form_data = data
      @response = http.request(post)
    end
  end
  
  def response
    @response
  end
  
end