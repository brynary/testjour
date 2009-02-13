require 'timeout'
require 'socket'

TCPSocket.class_eval do
  
  def self.wait_for_no_service(options)
    socket = nil
    Timeout::timeout(options[:timeout] || 20) do
      loop do
        begin
          socket = TCPSocket.new(options[:host], options[:port])
          socket.close unless socket.nil?
        rescue Errno::ECONNREFUSED
          return
        end
      end
    end
  end
  
  def self.wait_for_service(options)
    socket = nil
    Timeout::timeout(options[:timeout] || 20) do
      loop do
        begin
          socket = TCPSocket.new(options[:host], options[:port])
          return
        rescue Errno::ECONNREFUSED
          sleep 1.5
        end
      end
    end
  ensure
    socket.close unless socket.nil?
  end
  
end