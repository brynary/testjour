require "rubygems"
require "spec"
require "fileutils"
require "net/http"

require File.expand_path(File.dirname(__FILE__) + "/../lib/testjour/core_extensions/wait_for_service")

Spec::Runner.configure do |config|

  def start_queue
    $tjqueue_pid = fork do
      Dir.chdir(File.join(File.dirname(__FILE__), "..", "bin"))
      exec "ruby httpq"
    end
    
    TCPSocket.wait_for_service :host => "0.0.0.0", :port => 15434
  end
  
  def shutdown_queue
    Process.kill "INT", $tjqueue_pid
    Process.wait($tjqueue_pid)
  end
  
  def get(path)
    with_http do |http|
      get = Net::HTTP::Get.new(path)
      @response = http.request(get)
    end
  end
  
  def post(path, data = {})
    with_http do |http|
      post = Net::HTTP::Post.new(path)
      post.form_data = data
      @response = http.request(post)
    end
  end
  
  def with_http(&block)
    Net::HTTP.start("0.0.0.0", 15434, &block)
  end
  
  def response
    @response
  end
  
end