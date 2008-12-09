require "drb"

require "testjour/commands/base_command"
require "testjour/queue_server"
require "testjour/bonjour"

module Testjour
  module CLI
    
    class Run < BaseCommand
      def self.command
        "run"
      end
      
      def initialize(*args)
        Testjour.logger.debug "Runner command #{self.class}..."
        Testjour.load_cucumber
        
        super
        @found_server = 0
        require "testjour/cucumber_extensions/queueing_executor"
        require "testjour/colorer"
      end
      
      def run
        Testjour::QueueServer.with_server do |queue|
          start_local_runners unless servers_specified?
          start_slave_runners
          queue_features(queue)
          
          if @found_server.zero?
            puts "No processes to build on. Aborting."
          else
            print_results
          end
        end
      end
      
      def disable_cucumber_require
        Cucumber::CLI.class_eval do
          def require_files
            ARGV.clear # Shut up RSpec
          end
        end
      end
      
      def queue_features(queue)
        Testjour.logger.debug "Queueing features..."
        disable_cucumber_require
        ARGV.replace(@non_options.clone)
        Cucumber::CLI.executor = Testjour::QueueingExecutor.new(queue, Cucumber::CLI.step_mother)
        Cucumber::CLI.execute
      end
      
      def print_results
        puts
        puts "Building on #{@found_server} processes..."
        puts
  
        Cucumber::CLI.executor.wait_for_results
        Testjour.logger.debug "DONE"
      end
      
      def slave_servers_to_use
        # require "rubygems"; require "ruby-debug"; Debugger.start; debugger
        @slave_servers_to_use ||= available_servers.select do |potential_server|
          !servers_specified? || specified_servers_include?(potential_server)
        end
      end
      
      def available_servers
        @available_servers ||= Testjour::Bonjour.list
      end
      
      def request_build_from(server)
        slave_server = DRbObject.new(nil, server.uri)
        result = slave_server.run(testjour_uri, @non_options)
  
        if result
          Testjour.logger.info "Requesting buld from available server: #{server.uri}. Accepted."
          @found_server += 1
        else
          Testjour.logger.info "Requesting buld from available server: #{server.uri}. Rejected."
        end
      end
      
      def start_local_runners
        2.times do 
          start_local_runner
        end
      end
      
      def start_slave_runners
        slave_servers_to_use.each do |server|
          request_build_from(server)
        end
      end
      
      def start_local_runner
        pid_queue = Queue.new

        Thread.new do
          Thread.current.abort_on_exception = true
          cmd = command_for_local_run
          Testjour.logger.debug "Starting local:run with command: #{cmd}"
          status, stdout, stderr = systemu(cmd) { |pid| pid_queue << pid }
          Testjour.logger.warn stderr if stderr.strip.size > 0
        end

        pid = pid_queue.pop
        
        @found_server += 1
        Testjour.logger.info "Started local:run on PID #{pid}"
        
        pid
      end
      
      def command_for_local_run
        "#{testjour_bin_path} local:run #{testjour_uri} -- #{@non_options.join(' ')}".strip
      end

      def testjour_bin_path
        File.expand_path(File.dirname(__FILE__) + "/../../../bin/testjour")
      end
      
      def testjour_uri
        uri = URI.parse(DRb.uri)
        uri.path = File.expand_path(".")
        uri.scheme = "testjour"
        uri.user = `whoami`.strip
        uri.to_s
      end
      
      def specified_servers_include?(potential_server)
        @options[:server].any? do |specified_server|
          potential_server.host.include?(specified_server)
        end
      end
      
      def servers_specified?
        @options[:server] && @options[:server].any?
      end
      
      def option_parser
        OptionParser.new do |opts|
          opts.on("--on SERVER", "Specify a pattern to exclude servers to. Disabled local runners") do |server|
            @options[:server] ||= []
            @options[:server] << server
          end
        end
      end
    end
   
    Parser.register_command Run
  end
end