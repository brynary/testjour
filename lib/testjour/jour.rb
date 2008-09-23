require "rubygems"
require "dnssd"
require "set"

Thread.abort_on_exception = true

module Testjour
  Server  = Struct.new(:name, :host, :port)
  PORT    = 8808
  SERVICE = "_testjour._tcp"  
  
  class Jour
    
    def self.list
      hosts = []

      service = DNSSD.browse(SERVICE) do |reply|
        DNSSD.resolve(reply.name, reply.type, reply.domain) do |rr|
          host = Server.new(reply.name, rr.target, rr.port)
          unless hosts.include? host
            puts "#{host.name} (#{host.host}:#{host.port})"
            hosts << host
          end
        end
      end

      sleep 5
      service.stop
    end
    
    def self.serve
      name = ENV['USER'] if name.empty?

      tr = DNSSD::TextRecord.new
      tr['description'] = "#{name}'s gem server"

      DNSSD.register(name, SERVICE, "local", port, tr.encode) do |reply|
        puts "Ready to run tests under name '#{name}'..."
      end

      sleep 60
    end
  end
  
end