require File.dirname(__FILE__) + "/queue_server"
require "drb"
require "timeout"

DRb.start_service
@ro = DRbObject.new(nil, 'druby://0.0.0.0:1337')

loop do
  print @ro.take_result
end