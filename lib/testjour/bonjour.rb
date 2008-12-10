require "dnssd"
require "set"

Thread.abort_on_exception = true

module Testjour
  SERVICE = "_testjour._tcp"  
  
  module Bonjour
    
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
      
      def status_line
        "    %-12s %s %s" % [name, colored_status, "#{host}:#{port}"]
      end
      
    protected
    
      def colored_status
        formatted_status = ("%-12s" % status)
        return formatted_status unless defined?(Testjour::Colorer)

        case formatted_status.strip
        when "available"
          Testjour::Colorer.green(formatted_status)
        else
          Testjour::Colorer.yellow(formatted_status)
        end
      end
      
      def status
        drb_object.status
      end
      
      def drb_object
        @drb_object ||= DRbObject.new(nil, server.uri)
      end
    end
    
    def bonjour_servers
      return @bonjour_servers if !@bonjour_servers.nil?
      
      @bonjour_servers = []

      service = DNSSD.browse(SERVICE) do |reply|
        DNSSD.resolve(reply.name, reply.type, reply.domain) do |rr|
          server = Server.new(reply.name, rr.target, rr.port)
          @bonjour_servers << server unless hosts.any? { |h| h == server }
        end
      end

      sleep 3
      service.stop
      return @bonjour_servers
    end
    
    def bonjour_serve(port)
      name = ENV['USER']

      tr = DNSSD::TextRecord.new
      tr['description'] = "#{name}'s testjour server"

      DNSSD.register(name, SERVICE, "local", port, tr.encode) do |reply|
        Testjour.logger.info "Broadcasting: Ready to run tests under name '#{name}' on port #{port}..."
      end
    end
  end
  
end