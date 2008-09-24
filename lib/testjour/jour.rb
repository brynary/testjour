require "rubygems"
require "dnssd"
require "set"

Thread.abort_on_exception = true

module Testjour
  Server  = Struct.new(:name, :host, :port)
  SERVICE = "_testjour._tcp"  
  
  class Jour
    
    def self.list
      hosts = []

      service = DNSSD.browse(SERVICE) do |reply|
        DNSSD.resolve(reply.name, reply.type, reply.domain) do |rr|
          hosts << Server.new(reply.name, rr.target, rr.port)
        end
      end

      sleep 3
      service.stop
      hosts.uniq
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