require File.dirname(__FILE__) + "/queue_server"
require "drb"
require "timeout"

DRb.start_service
@ro = DRbObject.new(nil, Testjour::DRB_URL)

loop do
  print @ro.take_result
end