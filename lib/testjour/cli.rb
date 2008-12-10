module Testjour
  module CLI

    class NoCommandGiven < StandardError
      def message
        "No command given"
      end
    end

    class UnknownCommand < StandardError
      def initialize(command_name)
        @command_name = command_name
      end

      def message
        "Unknown command: #{@command_name.inspect}"
      end
    end

    def self.execute
      Parser.new.execute
    end
    
    class Parser
      class << self
        attr_accessor :commands
        
        def register_command(klass)
          @commands << klass
        end
      end
      
      self.commands = []

      def execute
        raise NoCommandGiven if ARGV.empty?
        raise UnknownCommand.new(command_name) unless command_klass
        
        args = ARGV.dup
        args.shift # Remove subcommand name
        
        command_klass.new(self, args).run
      rescue NoCommandGiven, UnknownCommand
        exit_with_usage
      end
      
      def command_klass
        self.class.commands.detect do |command_klass|
          command_klass.command == command_name
        end
      end

      def command_name
        ARGV.first
      end
      
      def exit_with_usage
        $stderr.puts "ERROR: #{$!.message}"
        $stderr.puts usage
        exit 1
      end
      
      def usage
        message = []
        message << "usage: testjour <SUBCOMMAND> [OPTIONS] [ARGS...]"
        message << "Type 'testjour help <SUBCOMMAND>' for help on a specific subcommand."
        message << "Type 'testjour version' to get this program's version."
        message << ""
        message << "Available subcommands are:"
        message += command_listing
        message.map { |line| line.chomp }.join("\n")
      end
      
      def command_listing
        self.class.commands.sort_by { |c| c.command }.map do |command_klass|
          "  " + command_klass.command
        end
      end
      
    end
    
  end
end