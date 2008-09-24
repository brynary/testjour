require "rubygems"
require "dnssd"
require "set"

Thread.abort_on_exception = true

module Testjour
  SERVICE = "_testjour._tcp"  
  
  class Jour
    
    class Server
      attr_reader :name, :host, :port
      
      def initialize(name, host, port)
        @name = name
        @host = host
        @port = port
      end
      
      def ==(other)
        other.class == self.class && other.uri == self.uri
      end
      
      def uri
        "druby://" + @host.gsub(/\.$/, "") + ":" + @port.to_s
      end
    end
    
    def self.list
      hosts = []

      service = DNSSD.browse(SERVICE) do |reply|
        DNSSD.resolve(reply.name, reply.type, reply.domain) do |rr|
          server = Server.new(reply.name, rr.target, rr.port)
          hosts << server unless hosts.any? { |h| h == server }
        end
      end

      sleep 3
      service.stop
      return hosts
    end
    
    def self.serve(port)
      name = ENV['USER']

      tr = DNSSD::TextRecord.new
      tr['description'] = "#{name}'s testjour server"

      DNSSD.register(name, SERVICE, "local", port, tr.encode) do |reply|
        puts "Broadcasting: Ready to run tests under name '#{name}' on port #{port}..."
        puts
      end
    end
  end
  
end